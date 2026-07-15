import { apiFetch } from "@/lib/api";
import type { ActivityItem, ChartDataPoint, DashboardStats } from "@/types";

export const EMPTY_DASHBOARD_STATS: DashboardStats = {
  totalUsers: 0,
  totalDrivers: 0,
  activeDrivers: 0,
  activeRides: 0,
  completedRides: 0,
  cancelledRides: 0,
  todayRevenue: 0,
  monthlyRevenue: 0,
  totalRevenue: 0,
  driverEarningsToday: 0,
  companyEarningsToday: 0,
  totalCommissionPaid: 0,
  driverCommissionPercentage: 0,
};

export interface DashboardCharts {
  rideBooking: ChartDataPoint[];
  revenue: ChartDataPoint[];
  userGrowth: ChartDataPoint[];
  driverGrowth: ChartDataPoint[];
}

export interface OnlineDriverItem {
  id: string;
  name: string;
  vehicleType: string;
  status: string;
}

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

export async function fetchDashboardCharts(): Promise<DashboardCharts> {
  const res = await apiFetch<Record<string, unknown>>("/api/v1/admin/dashboard/charts");
  const toChartPoints = (items: unknown): ChartDataPoint[] =>
    Array.isArray(items)
      ? items.map((item) => item as ChartDataPoint)
      : [];

  return {
    rideBooking: toChartPoints(res.rideBooking),
    revenue: toChartPoints(res.revenue),
    userGrowth: toChartPoints(res.userGrowth),
    driverGrowth: toChartPoints(res.driverGrowth),
  };
}

export async function fetchDashboardActivities(): Promise<ActivityItem[]> {
  const res = await apiFetch<ActivityItem[]>("/api/v1/admin/dashboard/activities");
  return Array.isArray(res) ? res : [];
}

export async function fetchOnlineDrivers(): Promise<OnlineDriverItem[]> {
  const res = await apiFetch<OnlineDriverItem[]>("/api/v1/admin/dashboard/online-drivers");
  return Array.isArray(res) ? res : [];
}
