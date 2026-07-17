"use client";

import { useCallback, useEffect, useState } from "react";
import type { AuthSession } from "@/lib/auth-session";
import { getAuthSession } from "@/lib/auth-session";
import { getProfile, type Profile } from "@/lib/profile-api";

const DEFAULT_RATING = 4.9;

export interface AuthUserDisplay {
  name: string;
  phone: string;
  email: string;
  initial: string;
  rating: number;
  profileImageUrl?: string | null;
  isLoading: boolean;
}

const DEFAULT_USER: AuthUserDisplay = {
  name: "Bull Wave rides User",
  phone: "",
  email: "Add email",
  initial: "?",
  rating: DEFAULT_RATING,
  isLoading: true,
};

export function getNameInitial(name: string): string {
  const trimmed = name.trim();
  if (!trimmed) return "?";
  const parts = trimmed.split(/\s+/).filter(Boolean);
  if (parts.length >= 2) {
    return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
  }
  return parts[0][0].toUpperCase();
}

export function getDisplayName(session: Pick<AuthSession, "name">): string {
  const name = session.name?.trim();
  return name || "Bull Wave rides User";
}

export function sessionToUserDisplay(
  session: AuthSession,
  profile?: Profile | null
): AuthUserDisplay {
  const name = profile?.full_name?.trim() || getDisplayName(session);
  const email = profile?.email?.trim() || session.email?.trim();

  return {
    name,
    phone: profile?.phone || session.phone,
    email: email || "Add email",
    initial: getNameInitial(name),
    rating: profile?.rating_avg ?? DEFAULT_RATING,
    profileImageUrl: profile?.profile_image_url,
    isLoading: false,
  };
}

export function useAuthUser(): AuthUserDisplay {
  const [user, setUser] = useState<AuthUserDisplay>(DEFAULT_USER);

  const sync = useCallback(async () => {
    const session = getAuthSession();
    if (!session?.accessToken) {
      setUser(session ? { ...sessionToUserDisplay(session), isLoading: false } : { ...DEFAULT_USER, isLoading: false });
      return;
    }

    try {
      const profile = await getProfile();
      setUser(sessionToUserDisplay(session, profile));
    } catch {
      setUser({ ...sessionToUserDisplay(session), isLoading: false });
    }
  }, []);

  useEffect(() => {
    void sync();
    window.addEventListener("storage", sync);
    window.addEventListener("wavego-auth-update", sync);
    return () => {
      window.removeEventListener("storage", sync);
      window.removeEventListener("wavego-auth-update", sync);
    };
  }, [sync]);

  return user;
}
