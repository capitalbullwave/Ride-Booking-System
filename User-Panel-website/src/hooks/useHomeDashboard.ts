"use client";

import { useEffect, useState } from "react";
import { getHomeDashboard, type HomeDashboard } from "@/lib/home-api";
import { getUnreadNotificationCount } from "@/lib/notifications-api";

export function useHomeDashboard() {
  const [data, setData] = useState<HomeDashboard | null>(null);
  const [unreadCount, setUnreadCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setIsLoading(true);
      setError(null);
      try {
        const [dashboard, unread] = await Promise.all([
          getHomeDashboard(),
          getUnreadNotificationCount().catch(() => ({ count: 0 })),
        ]);
        if (!cancelled) {
          setData(dashboard);
          setUnreadCount(unread.count);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : "Failed to load home data");
        }
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    }

    void load();
    return () => {
      cancelled = true;
    };
  }, []);

  return { data, unreadCount, isLoading, error };
}
