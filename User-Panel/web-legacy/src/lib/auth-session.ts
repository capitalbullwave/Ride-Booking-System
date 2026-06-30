import {
  AUTH_COOKIE_NAME,
  AUTH_SESSION_KEY,
  DEV_OTP_HINT_KEY,
  POST_LOGIN_REDIRECT_KEY,
  PENDING_OTP_PHONE_KEY,
} from "@/constants/auth";
import { ROUTES } from "@/constants/routes";

export interface AuthSession {
  phone: string;
  verified: true;
  name?: string;
  email?: string;
  accessToken?: string;
  refreshToken?: string;
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
  sessionStorage.setItem(AUTH_SESSION_KEY, JSON.stringify(session));
  document.cookie = `${AUTH_COOKIE_NAME}=1; path=/; max-age=86400; SameSite=Lax`;
  window.dispatchEvent(new Event("wavego-auth-update"));
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
  return getAuthSession() !== null;
}

export function getProtectedPath(path: string): string {
  if (isAuthenticated()) return path;
  return `${ROUTES.login}?next=${encodeURIComponent(path)}`;
}

export function clearAuthSession() {
  if (typeof window === "undefined") return;
  sessionStorage.removeItem(AUTH_SESSION_KEY);
  clearPendingOtpPhone();
  clearPostLoginRedirect();
  document.cookie = `${AUTH_COOKIE_NAME}=; path=/; max-age=0`;
}

export function hasAuthCookie(): boolean {
  if (typeof document === "undefined") return false;
  return document.cookie.split(";").some((c) => c.trim().startsWith(`${AUTH_COOKIE_NAME}=1`));
}
