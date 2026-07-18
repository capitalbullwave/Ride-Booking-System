import {
  AUTH_COOKIE_NAME,
  AUTH_SESSION_KEY,
  DEV_OTP_HINT_KEY,
  POST_LOGIN_REDIRECT_KEY,
  PENDING_OTP_PHONE_KEY,
  PROFILE_COMPLETE_COOKIE,
} from "@/constants/auth";
import { ROUTES } from "@/constants/routes";

export interface AuthSession {
  phone: string;
  verified: true;
  name?: string;
  email?: string;
  accessToken?: string;
  refreshToken?: string;
  profileComplete?: boolean;
}

export function needsProfileSetup(name?: string | null): boolean {
  const trimmed = name?.trim();
  if (!trimmed) return true;
  return trimmed.toLowerCase() === "user";
}

function syncProfileCompleteCookie(profileComplete: boolean) {
  if (typeof document === "undefined") return;
  if (profileComplete) {
    document.cookie = `${PROFILE_COMPLETE_COOKIE}=1; path=/; max-age=86400; SameSite=Lax`;
  } else {
    document.cookie = `${PROFILE_COMPLETE_COOKIE}=; path=/; max-age=0`;
  }
}

export function setPendingOtpPhone(phone: string) {
  if (typeof window === "undefined") return;
  sessionStorage.setItem(PENDING_OTP_PHONE_KEY, phone);
}

export function setPostLoginRedirect(path: string) {
  if (typeof window === "undefined") return;
  if (!path) return;
  sessionStorage.setItem(POST_LOGIN_REDIRECT_KEY, path);
}

export function getPostLoginRedirect(): string | null {
  if (typeof window === "undefined") return null;
  return sessionStorage.getItem(POST_LOGIN_REDIRECT_KEY);
}

export function clearPostLoginRedirect() {
  if (typeof window === "undefined") return;
  sessionStorage.removeItem(POST_LOGIN_REDIRECT_KEY);
}

export function getPendingOtpPhone(): string | null {
  if (typeof window === "undefined") return null;
  return sessionStorage.getItem(PENDING_OTP_PHONE_KEY);
}

export function clearPendingOtpPhone() {
  if (typeof window === "undefined") return;
  sessionStorage.removeItem(PENDING_OTP_PHONE_KEY);
  sessionStorage.removeItem(DEV_OTP_HINT_KEY);
}

export function setDevOtpHint(code: string) {
  if (typeof window === "undefined") return;
  sessionStorage.setItem(DEV_OTP_HINT_KEY, code);
}

export function getDevOtpHint(): string | null {
  if (typeof window === "undefined") return null;
  return sessionStorage.getItem(DEV_OTP_HINT_KEY);
}

export function setAuthSession(session: AuthSession) {
  if (typeof window === "undefined") return;
  const profileComplete =
    session.profileComplete ?? !needsProfileSetup(session.name);
  const normalized: AuthSession = { ...session, profileComplete };
  sessionStorage.setItem(AUTH_SESSION_KEY, JSON.stringify(normalized));
  document.cookie = `${AUTH_COOKIE_NAME}=1; path=/; max-age=86400; SameSite=Lax`;
  syncProfileCompleteCookie(profileComplete);
  window.dispatchEvent(new Event("wavego-auth-update"));
}

export function markProfileComplete(updates?: { name?: string; email?: string }) {
  const session = getAuthSession();
  if (!session) return;
  setAuthSession({
    ...session,
    ...(updates?.name?.trim() ? { name: updates.name.trim() } : {}),
    ...(updates?.email?.trim() ? { email: updates.email.trim() } : {}),
    profileComplete: true,
  });
}

export function isProfileComplete(): boolean {
  const session = getAuthSession();
  if (!session) return false;
  return session.profileComplete ?? !needsProfileSetup(session.name);
}

export function getAuthSession(): AuthSession | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = sessionStorage.getItem(AUTH_SESSION_KEY);
    if (!raw) return null;
    const session = JSON.parse(raw) as AuthSession;
    if (session.verified !== true || !session.phone) return null;
    return session;
  } catch {
    return null;
  }
}

export function isAuthenticated(): boolean {
  const session = getAuthSession();
  // Require a real API token — cookie alone is not enough to book/search.
  return Boolean(session?.accessToken);
}

export function requireAuthRedirect(returnPath: string): string {
  const next = returnPath.startsWith("/") ? returnPath : `/${returnPath}`;
  return `${ROUTES.login}?next=${encodeURIComponent(next)}&redirect=${encodeURIComponent(next)}`;
}

export function getProtectedPath(path: string): string {
  if (isAuthenticated()) return path;
  // Stale auth cookie without sessionStorage token — clear it so middleware matches.
  if (hasAuthCookie() && !getAuthSession()?.accessToken) {
    clearAuthSession();
  }
  return requireAuthRedirect(path);
}

export function clearAuthSession() {
  if (typeof window === "undefined") return;
  sessionStorage.removeItem(AUTH_SESSION_KEY);
  clearPendingOtpPhone();
  clearPostLoginRedirect();
  document.cookie = `${AUTH_COOKIE_NAME}=; path=/; max-age=0`;
  syncProfileCompleteCookie(false);
}

export function resolvePostAuthDestination(): string {
  const redirectTo = getPostLoginRedirect();
  if (redirectTo) {
    clearPostLoginRedirect();
    return redirectTo;
  }
  return ROUTES.home;
}

export function hasAuthCookie(): boolean {
  if (typeof document === "undefined") return false;
  return document.cookie.split(";").some((c) => c.trim().startsWith(`${AUTH_COOKIE_NAME}=1`));
}
