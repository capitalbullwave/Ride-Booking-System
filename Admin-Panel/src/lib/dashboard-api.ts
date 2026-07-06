import { apiFetch } from "@/lib/api";
import type { DashboardStats } from "@/types";

export async function fetchDashboardStats(): Promise<DashboardStats> {
  const res = await apiFetch<Record<string, unknown>>("/api/v1/admin/dashboard/stats");
  return {
    totalUsers: Number(res.totalUsers ?? 0),
    totalDrivers: Number(res.totalDrivers ?? 0),
    activeDrivers: Number(res.activeDrivers ?? 0),
    activeRides: Number(res.activeRides ?? 0),
    completedRides: Number(res.completedRides ?? 0),
    cancelledRides: Number(res.cancelledRides ?? 0),
    todayRevenue: Number(res.todayRevenue ?? 0),
    monthlyRevenue: Number(res.monthlyRevenue ?? 0),
    totalRevenue: Number(res.totalRevenue ?? 0),
    driverEarningsToday: Number(res.driverEarningsToday ?? 0),
    companyEarningsToday: Number(res.companyEarningsToday ?? 0),
    totalCommissionPaid: Number(res.totalCommissionPaid ?? 0),
    driverCommissionPercentage: Number(res.driverCommissionPercentage ?? 0),
  };
}
