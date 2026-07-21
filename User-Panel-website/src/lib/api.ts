import { getAuthSession } from "@/lib/auth-session";



export const USER_API = "/api/v1/user";

export const AUTH_API = "/api/v1/auth";

export const COMMON_API = "/api/v1/common";

export const PUBLIC_API = "/api/v1/public";



export function resolveUserPath(path: string): string {
  if (
    path.startsWith(USER_API) ||
    path.startsWith(AUTH_API) ||
    path.startsWith(COMMON_API) ||
    path.startsWith(PUBLIC_API) ||
    path.startsWith("/api/v1/rides/") ||
    path.startsWith("/api/v1/corporate/")
  ) {
    return path;
  }

  if (path.startsWith("/api/v1/user-panel")) {
    return path.replace("/api/v1/user-panel", USER_API);
  }

  // Match Flutter: base /api/v1 + /rides/estimate (not under /user).
  if (path.startsWith("/rides/estimate")) {
    return `/api/v1${path}`;
  }

  // Match Flutter: /public/places/* → /api/v1/public/places/*
  if (path.startsWith("/public/")) {
    return `/api/v1${path}`;
  }

  if (path.startsWith("/common/")) {
    return `${COMMON_API}${path.slice("/common".length)}`;
  }

  if (path.startsWith("/api/v1/")) {
    return path.replace("/api/v1/", `${USER_API}/`).replace("/auth/user/", "/auth/");
  }

  if (path.startsWith("/auth/")) {
    return `${AUTH_API}${path.slice(5)}`;
  }

  // Paths like "/user/student-pass" must not become "/api/v1/user/user/...".
  if (path.startsWith("/user/")) {
    return `${USER_API}${path.slice("/user".length)}`;
  }

  return `${USER_API}${path.startsWith("/") ? path : `/${path}`}`;
}



/** Default backend — Render staging (avoids 503 from local 127.0.0.1). */
const STAGING_API_URL = "https://ride-application-backend.onrender.com";

function defaultApiBaseUrl(): string {
  return STAGING_API_URL;
}

export function getApiBaseUrl(): string {
  if (typeof window !== "undefined") {
    return process.env.NEXT_PUBLIC_API_URL || defaultApiBaseUrl();
  }

  return (
    process.env.NEXT_PUBLIC_API_URL ||
    process.env.BACKEND_URL ||
    defaultApiBaseUrl()
  );
}

const RETRYABLE_STATUS = new Set([502, 503, 504]);
const MAX_RETRIES = 3;

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/** Wake a sleeping Render/free-tier backend before the user hits a real API call. */
export async function warmBackend(timeoutMs = 45_000): Promise<void> {
  const base = getApiBaseUrl().replace(/\/$/, "");
  if (!base || base.includes("127.0.0.1") || base.includes("localhost")) {
    return;
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  try {
    await fetch(`${base}/health`, {
      method: "GET",
      cache: "no-store",
      signal: controller.signal,
    });
  } catch {
    // Warmup is best-effort; real requests still retry on 503.
  } finally {
    clearTimeout(timer);
  }
}

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



export function getErrorMessage(payload: unknown, fallback: string): string {

  if (!payload || typeof payload !== "object") return fallback;



  const record = payload as Record<string, unknown>;

  if (typeof record.message === "string") return record.message;



  const detail = record.detail;

  if (typeof detail === "string") return detail;

  if (Array.isArray(detail) && detail.length > 0) {

    const messages = detail

      .map((item) => {

        if (typeof item === "string") return item;

        if (item && typeof item === "object" && "msg" in item) {

          return String((item as { msg: unknown }).msg);

        }

        return null;

      })

      .filter(Boolean);

    if (messages.length > 0) return messages.join(". ");

  }

  return fallback;

}



function buildAuthHeaders(init?: RequestInit): HeadersInit {

  const headers: Record<string, string> = {

    "Content-Type": "application/json",

    ...(init?.headers as Record<string, string> | undefined),

  };



  if (typeof window !== "undefined") {

    const token = getAuthSession()?.accessToken;

    if (token) {

      headers.Authorization = `Bearer ${token}`;

    }

  }



  return headers;

}



export async function apiFetch<T>(
  path: string,
  init?: RequestInit,
  fallbackError = "Request failed"
): Promise<T> {
  const url = `${getApiBaseUrl()}${resolveUserPath(path)}`;
  const headers = buildAuthHeaders(init);
  let response: Response | null = null;

  for (let attempt = 0; attempt <= MAX_RETRIES; attempt += 1) {
    try {
      response = await fetch(url, {
        ...init,
        headers,
      });
    } catch (error) {
      if (attempt < MAX_RETRIES) {
        await sleep(800 * (attempt + 1));
        continue;
      }
      throw error instanceof Error
        ? error
        : new Error("Network error. Please try again.");
    }

    if (response.ok || !RETRYABLE_STATUS.has(response.status) || attempt === MAX_RETRIES) {
      break;
    }

    // Render free tier often returns 503 while waking from idle.
    await sleep(1000 * (attempt + 1));
  }

  if (!response) {
    throw new Error(fallbackError);
  }

  if (!response.ok) {
    const errorBody = await response.json().catch(() => null);
    const message =
      response.status === 503
        ? getErrorMessage(
            errorBody,
            "Server is waking up. Please wait a few seconds and try again."
          )
        : getErrorMessage(errorBody, fallbackError);
    throw new Error(message);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
}



export function authFetch<T>(

  path: string,

  init?: RequestInit,

  fallbackError = "Request failed"

): Promise<T> {

  return apiFetch<T>(path.startsWith("/") ? path : `/${path}`, init, fallbackError);

}

