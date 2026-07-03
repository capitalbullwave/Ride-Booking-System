import { getAuthSession } from "@/lib/auth-session";



export const USER_API = "/api/v1/user";

export const AUTH_API = "/api/v1/auth";

export const COMMON_API = "/api/v1/common";

export const PUBLIC_API = "/api/v1/public";



function resolveUserPath(path: string): string {

  if (path.startsWith(USER_API) || path.startsWith(AUTH_API) || path.startsWith(COMMON_API) || path.startsWith(PUBLIC_API)) {

    return path;

  }

  if (path.startsWith("/api/v1/user-panel")) {

    return path.replace("/api/v1/user-panel", USER_API);

  }

  if (path.startsWith("/api/v1/")) {

    return path.replace("/api/v1/", `${USER_API}/`).replace("/auth/user/", "/auth/");

  }

  if (path.startsWith("/auth/")) {

    return `${AUTH_API}${path.slice(5)}`;

  }

  return `${USER_API}${path.startsWith("/") ? path : `/${path}`}`;

}



export function getApiBaseUrl(): string {

  if (typeof window !== "undefined") {

    return process.env.NEXT_PUBLIC_API_URL ?? "";

  }

  return process.env.NEXT_PUBLIC_API_URL ?? process.env.BACKEND_URL ?? "http://127.0.0.1:8000";

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

  const response = await fetch(`${getApiBaseUrl()}${resolveUserPath(path)}`, {

    ...init,

    headers: buildAuthHeaders(init),

  });



  if (!response.ok) {

    const errorBody = await response.json().catch(() => null);

    throw new Error(getErrorMessage(errorBody, fallbackError));

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

