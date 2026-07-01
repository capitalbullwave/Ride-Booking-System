import { getStoredSession } from "@/lib/auth";

export function getApiBaseUrl(): string {
  return process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";
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

  const response = await fetch(`${getApiBaseUrl()}${path}`, {
    ...options,
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...(session?.token
        ? { Authorization: `Bearer ${session.token}` }
        : {}),
      ...options.headers,
    },
  });

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
