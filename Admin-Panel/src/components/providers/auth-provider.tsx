"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import { useRouter } from "next/navigation";
import {
  AuthSession,
  AuthUser,
  AUTH_STORAGE_KEY,
  clearAuthCookie,
  clearSession,
  DEFAULT_ADMIN_PHONE,
  getStoredSession,
  setAuthCookie,
  storePassword,
  storeSession,
  updateStoredUser,
  validateCredentials,
} from "@/lib/auth";
import { apiFetch } from "@/lib/api";

interface AuthContextValue {
  user: AuthUser | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (
    email: string,
    password: string,
    remember?: boolean,
  ) => Promise<{ success: boolean; error?: string }>;
  logout: () => void;
  updateProfile: (updates: Pick<AuthUser, "name" | "email" | "phone">) => { success: boolean; error?: string };
  updatePassword: (currentPassword: string, newPassword: string) => { success: boolean; error?: string };
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    async function restoreSession() {
      const session = getStoredSession();
      if (!session?.token) {
        clearAuthCookie();
        setUser(null);
        setIsLoading(false);
        return;
      }

      try {
        const currentUser = await apiFetch<AuthUser>("/api/v1/admin/me", {
          headers: {
            Authorization: `Bearer ${session.token}`,
          },
        });
        const remembered = localStorage.getItem(AUTH_STORAGE_KEY) !== null;
        setAuthCookie(remembered);
        setUser(currentUser);
      } catch {
        clearSession();
        setUser(null);
      } finally {
        setIsLoading(false);
      }
    }

    void restoreSession();
  }, []);

  const login = useCallback(async (email: string, password: string, remember = true) => {
    try {
      // Drop stale tokens so login is not affected by expired sessions.
      clearSession();

      const data = await apiFetch<{
        user: AuthUser;
        accessToken: string;
        refreshToken: string;
        expiresAt: number;
      }>("/api/v1/admin/login", {
        method: "POST",
        body: JSON.stringify({ email, password }),
        skipAuth: true,
        skipRefresh: true,
      });

      const session: AuthSession = {
        user: data.user,
        token: data.accessToken,
        refreshToken: data.refreshToken,
        expiresAt:
          data.expiresAt > 1_000_000_000_000
            ? data.expiresAt
            : data.expiresAt * 1000,
      };

      storeSession(session, remember);
      storePassword(password);
      setAuthCookie(remember);
      setUser(data.user);
      return { success: true };
    } catch (error) {
      const message = error instanceof Error ? error.message : "Login failed";
      return { success: false, error: message };
    }
  }, []);

  const logout = useCallback(() => {
    const session = getStoredSession();
    if (session?.token) {
      void apiFetch("/api/v1/admin/logout", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${session.token}`,
        },
      }).catch(() => undefined);
    }

    clearSession();
    setUser(null);
    router.push("/login");
  }, [router]);

  const updateProfile = useCallback(
    (updates: Pick<AuthUser, "name" | "email" | "phone">) => {
      const name = updates.name.trim();
      const email = updates.email.trim().toLowerCase();
      const phone = updates.phone.trim();

      if (!name) {
        return { success: false, error: "Name is required" };
      }
      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        return { success: false, error: "Enter a valid email address" };
      }
      if (!phone) {
        return { success: false, error: "Phone number is required" };
      }

      const updatedUser = updateStoredUser({ name, email, phone });
      if (!updatedUser) {
        return { success: false, error: "You must be logged in to update your profile" };
      }

      setUser(updatedUser);
      return { success: true };
    },
    []
  );

  const updatePassword = useCallback((currentPassword: string, newPassword: string) => {
    if (!user) {
      return { success: false, error: "You must be logged in to update your password" };
    }

    const authUser = validateCredentials(user.email, currentPassword);
    if (!authUser) {
      return { success: false, error: "Current password is incorrect" };
    }
    if (newPassword.length < 6) {
      return { success: false, error: "New password must be at least 6 characters" };
    }

    storePassword(newPassword);
    return { success: true };
  }, [user]);

  const value = useMemo(
    () => ({
      user,
      isLoading,
      isAuthenticated: !!user,
      login,
      logout,
      updateProfile,
      updatePassword,
    }),
    [user, isLoading, login, logout, updateProfile, updatePassword]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return context;
}
