import { getStoredSession } from "@/lib/auth";

export function getApiBaseUrl(): string {
  return process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";
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
  const data = (await response.json()) as {
    access_token?: string;
    refresh_token?: string;
  };
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
  options: RequestInit = {},
): Promise<T> {
  const session =
    typeof window !== "undefined" ? getStoredSession() : null;

  const makeRequest = async (token?: string | null) => {
    return fetch(`${getApiBaseUrl()}${path}`, {
      ...options,
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        ...(token
          ? { Authorization: `Bearer ${token}` }
          : session?.token
            ? { Authorization: `Bearer ${session.token}` }
            : {}),
        ...options.headers,
      },
    });
  };

  let response = await makeRequest(null);

  // Access tokens expire in ~30 minutes; refresh once and retry.
  if (response.status === 401 && session?.refreshToken) {
    const newToken = await refreshAdminSession();
    if (newToken) {
      response = await makeRequest(newToken);
    }
  }

  if (!response.ok) {
    let message = "Request failed";
    try {
      const data = (await response.json()) as {
        detail?: string;
        message?: string;
      };
      message = data.message ?? data.detail ?? message;
    } catch {
      // ignore JSON parse errors
    }
    throw new Error(message);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  const contentType = response.headers.get("content-type") ?? "";
  if (!contentType.includes("application/json")) {
    throw new Error("Unexpected response from API. Please sign in again.");
  }

  return response.json() as Promise<T>;
}
