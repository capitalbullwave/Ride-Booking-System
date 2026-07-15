"use client";

import { useCallback, useEffect, useState } from "react";
import { useAuth } from "@/components/providers/auth-provider";
import { fetchDashboardCharts, type DashboardCharts } from "@/lib/dashboard-api";

export function useDashboardCharts() {
  const { isAuthenticated } = useAuth();
  const [charts, setCharts] = useState<DashboardCharts | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const load = useCallback(async () => {
    setIsLoading(true);
    try {
      setCharts(await fetchDashboardCharts());
    } catch {
      setCharts(null);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (isAuthenticated) {
      void load();
    }
  }, [isAuthenticated, load]);

  return { charts, isLoading };
}
