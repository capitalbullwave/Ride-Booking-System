import { getStoredSession } from "@/lib/auth";

/**
 * Use same-origin by default so Next.js rewrites can proxy requests to the backend.
 * This avoids browser CORS issues in production.
 */
const DEFAULT_API_BASE_URL = "";

const BACKEND_HINT =
  "Unable to reach the server. Please check your connection and try again.";

export type ApiFetchOptions = RequestInit & {
  /** Do not attach stored session token (use for /login). */
  skipAuth?: boolean;
  /** Do not try refresh-token retry on 401 (use for /login). */
  skipRefresh?: boolean;
};

export function getApiBaseUrl(): string {
  // In the browser, always go through same-origin so Next.js can proxy via rewrites
  // and we avoid cross-origin CORS/preflight issues.
  if (typeof window !== "undefined") return DEFAULT_API_BASE_URL;

  return process.env.NEXT_PUBLIC_API_URL ?? DEFAULT_API_BASE_URL;
}

async function readResponseBody(response: Response): Promise<string> {
  try {
    return await response.text();
  } catch {
    return "";
  }
}

function parseApiMessage(body: string): string | null {
  if (!body.trim()) return null;

  try {
    const data = JSON.parse(body) as {
      detail?: string;
      message?: string;
    };
    return data.message ?? data.detail ?? null;
  } catch {
    return null;
  }
}

async function parseJsonResponse<T>(response: Response): Promise<T> {
  if (response.status === 204) {
    return undefined as T;
  }

  const body = await readResponseBody(response);

  if (!body.trim()) {
    if (!response.ok) {
      throw new Error(
        response.status >= 500
          ? BACKEND_HINT
          : "The server returned an empty response. Please try again.",
      );
    }
    throw new Error(BACKEND_HINT);
  }

  const contentType = response.headers.get("content-type") ?? "";
  if (!contentType.includes("application/json")) {
    throw new Error(BACKEND_HINT);
  }

  try {
    return JSON.parse(body) as T;
  } catch {
    throw new Error(
      "Received an invalid response from the server. Please try again.",
    );
  }
}

async function refreshAdminSession(): Promise<string | null> {
  const session = typeof window !== "undefined" ? getStoredSession() : null;
  if (!session?.refreshToken) return null;

  const response = await fetch(`${getApiBaseUrl()}/api/v1/admin/refresh-token`, {
    method: "POST",
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
    },
    body: JSON.stringify({ refresh_token: session.refreshToken }),
  });

  if (!response.ok) return null;

  try {
    const data = await parseJsonResponse<{
      access_token?: string;
      refresh_token?: string;
    }>(response);
    if (!data.access_token) return null;

    // Update session in storage (avoid circular imports).
    try {
      const KEY = "wavego_admin_session";
      const raw = localStorage.getItem(KEY) ?? sessionStorage.getItem(KEY);
      if (raw) {
        const parsed = JSON.parse(raw) as Record<string, unknown>;
        const next: Record<string, unknown> = {
          ...parsed,
          token: data.access_token,
          ...(data.refresh_token ? { refreshToken: data.refresh_token } : {}),
        };
        const storage = localStorage.getItem(KEY) ? localStorage : sessionStorage;
        storage.setItem(KEY, JSON.stringify(next));
      }
    } catch {
      // ignore
    }

    return data.access_token;
  } catch {
    return null;
  }
}

/** Turn backend-relative upload paths into absolute URLs the browser can open. */
export function resolveMediaUrl(url: string | undefined | null): string | null {
  if (!url) return null;

  const trimmed = url.trim();
  if (!trimmed) return null;

  if (
    trimmed.startsWith("http://") ||
    trimmed.startsWith("https://") ||
    trimmed.startsWith("data:")
  ) {
    return trimmed;
  }

  const base = getApiBaseUrl().replace(/\/$/, "");
  const path = trimmed.startsWith("/") ? trimmed : `/${trimmed}`;
  return `${base}${path}`;
}

export async function apiFetch<T>(
  path: string,
  options: ApiFetchOptions = {},
): Promise<T> {
  const { skipAuth = false, skipRefresh = false, ...requestOptions } = options;
  const session =
    typeof window !== "undefined" && !skipAuth ? getStoredSession() : null;

  const makeRequest = async (token?: string | null) => {
    const authToken = token ?? session?.token;
    return fetch(`${getApiBaseUrl()}${path}`, {
      ...requestOptions,
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        ...(!skipAuth && authToken
          ? { Authorization: `Bearer ${authToken}` }
          : {}),
        ...requestOptions.headers,
      },
    });
  };

  const RETRYABLE = new Set([502, 503, 504]);
  const MAX_RETRIES = 3;
  const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

  let response: Response | null = null;

  for (let attempt = 0; attempt <= MAX_RETRIES; attempt += 1) {
    try {
      response = await makeRequest(null);
    } catch (error) {
      if (attempt < MAX_RETRIES) {
        await sleep(800 * (attempt + 1));
        continue;
      }
      throw error instanceof Error
        ? new Error(
            /failed to fetch|networkerror|load failed/i.test(error.message)
              ? BACKEND_HINT
              : error.message,
          )
        : new Error("Unable to connect. Please try again.");
    }

    if (!RETRYABLE.has(response.status) || attempt === MAX_RETRIES) {
      break;
    }

    // Render free tier often returns 503 while waking from idle.
    await sleep(1000 * (attempt + 1));
  }

  if (!response) {
    throw new Error(BACKEND_HINT);
  }

  // Access tokens expire in ~30 minutes; refresh once and retry.
  if (!skipRefresh && response.status === 401 && session?.refreshToken) {
    const newToken = await refreshAdminSession();
    if (newToken) {
      response = await makeRequest(newToken);
    }
  }

  if (!response.ok) {
    const body = await readResponseBody(response);
    const message =
      parseApiMessage(body) ??
      (response.status === 503
        ? "Server is waking up. Please wait a few seconds and try again."
        : response.status >= 500
          ? BACKEND_HINT
          : "Request failed");
    throw new Error(message);
  }

  return parseJsonResponse<T>(response);
}
