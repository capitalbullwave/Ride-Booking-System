export const AUTH_STORAGE_KEY = "wavego_admin_session";
export const AUTH_PASSWORD_KEY = "wavego_admin_password";
export const AUTH_COOKIE_NAME = "wavego_authenticated";

export const DEMO_CREDENTIALS = {
  email: "admin@ridebook.com",
  password: "Admin@123456",
} as const;

export const DEFAULT_ADMIN_PHONE = "+91 98765 00000";
export const DEFAULT_ADMIN_NAME = "Capital Bull Wave";

export interface AuthUser {
  email: string;
  name: string;
  role: string;
  phone: string;
}

export interface AuthSession {
  user: AuthUser;
  token: string;
  expiresAt: number;
}

export function createSession(user: AuthUser): AuthSession {
  return {
    user,
    token: `wg_${crypto.randomUUID?.() ?? Date.now()}`,
    expiresAt: Date.now() + 24 * 60 * 60 * 1000,
  };
}

function normalizeExpiresAt(expiresAt: number): number {
  // Support legacy sessions that stored Unix seconds instead of milliseconds.
  return expiresAt > 1_000_000_000_000 ? expiresAt : expiresAt * 1000;
}

export function getStoredSession(): AuthSession | null {
  if (typeof window === "undefined") return null;

  try {
    const raw =
      localStorage.getItem(AUTH_STORAGE_KEY) ?? sessionStorage.getItem(AUTH_STORAGE_KEY);
    if (!raw) return null;

    const session = JSON.parse(raw) as AuthSession;
    const expiresAt = normalizeExpiresAt(session.expiresAt);
    if (expiresAt < Date.now()) {
      clearSession();
      return null;
    }

    if (session.expiresAt !== expiresAt) {
      session.expiresAt = expiresAt;
    }

    let shouldPersist = false;

    if (session.user && !session.user.phone) {
      session.user.phone = DEFAULT_ADMIN_PHONE;
      shouldPersist = true;
    }

    if (session.user?.name === "Bull Wave Capital") {
      session.user.name = DEFAULT_ADMIN_NAME;
      shouldPersist = true;
    }

    if (shouldPersist) {
      storeSession(session);
    }

    return session;
  } catch {
    clearSession();
    return null;
  }
}

export function storeSession(session: AuthSession, remember = true) {
  const storage = remember ? localStorage : sessionStorage;
  storage.setItem(AUTH_STORAGE_KEY, JSON.stringify(session));
  (remember ? sessionStorage : localStorage).removeItem(AUTH_STORAGE_KEY);
}

export function setAuthCookie(remember = true) {
  if (typeof document === "undefined") return;

  const parts = [`${AUTH_COOKIE_NAME}=1`, "path=/", "SameSite=Lax"];
  if (remember) {
    parts.push(`max-age=${24 * 60 * 60}`);
  }
  document.cookie = parts.join("; ");
}

export function clearAuthCookie() {
  if (typeof document === "undefined") return;
  document.cookie = `${AUTH_COOKIE_NAME}=; path=/; max-age=0`;
}

export function getStoredPassword(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem(AUTH_PASSWORD_KEY);
}

export function storePassword(password: string) {
  localStorage.setItem(AUTH_PASSWORD_KEY, password);
}

export function clearPassword() {
  localStorage.removeItem(AUTH_PASSWORD_KEY);
}

export function updateStoredUser(updates: Partial<AuthUser>): AuthUser | null {
  const session = getStoredSession();
  if (!session) return null;

  const user: AuthUser = {
    ...session.user,
    ...updates,
  };

  storeSession({ ...session, user });
  return user;
}

export function clearSession() {
  localStorage.removeItem(AUTH_STORAGE_KEY);
  sessionStorage.removeItem(AUTH_STORAGE_KEY);
  clearPassword();
  clearAuthCookie();
}

export function validateCredentials(email: string, password: string): AuthUser | null {
  const normalizedEmail = email.trim().toLowerCase();
  const storedPassword = getStoredPassword();
  const validPassword =
    password === DEMO_CREDENTIALS.password ||
    (storedPassword !== null && password === storedPassword);

  if (normalizedEmail === DEMO_CREDENTIALS.email && validPassword) {
    const session = getStoredSession();
    if (session?.user) {
      return session.user;
    }

    return {
      email: DEMO_CREDENTIALS.email,
      name: DEFAULT_ADMIN_NAME,
      role: "Super Admin",
      phone: DEFAULT_ADMIN_PHONE,
    };
  }

  return null;
}
