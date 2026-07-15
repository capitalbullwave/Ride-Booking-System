"use client";

import { useCallback, useEffect, useState } from "react";
import {
  Users,
  Car,
  UserCheck,
  MapPin,
  CheckCircle,
  XCircle,
  IndianRupee,
  TrendingUp,
  Percent,
  Wallet,
  Building2,
  Loader2,
} from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatCard } from "@/components/shared/stat-card";
import {
  RideBookingChart,
  RevenueChart,
  UserGrowthChart,
  DriverGrowthChart,
} from "@/components/dashboard/charts";
import { LiveActivity, QuickActions, OnlineDriversCard } from "@/components/dashboard/live-activity";
import { useAuth } from "@/components/providers/auth-provider";
import {
  EMPTY_DASHBOARD_STATS,
  fetchDashboardActivities,
  fetchDashboardCharts,
  fetchDashboardStats,
  fetchOnlineDrivers,
  type DashboardCharts,
  type OnlineDriverItem,
} from "@/lib/dashboard-api";
import { formatCurrency, formatNumber } from "@/lib/format";
import type { ActivityItem, DashboardStats } from "@/types";
import { toast } from "sonner";

export default function DashboardPage() {
  const { isAuthenticated } = useAuth();
  const [stats, setStats] = useState<DashboardStats>(EMPTY_DASHBOARD_STATS);
  const [charts, setCharts] = useState<DashboardCharts | null>(null);
  const [activities, setActivities] = useState<ActivityItem[]>([]);
  const [onlineDrivers, setOnlineDrivers] = useState<OnlineDriverItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const load = useCallback(async () => {
    setIsLoading(true);
    try {
      const [statsResult, chartsResult, activitiesResult, driversResult] = await Promise.allSettled([
        fetchDashboardStats(),
        fetchDashboardCharts(),
        fetchDashboardActivities(),
        fetchOnlineDrivers(),
      ]);

      if (statsResult.status === "fulfilled") {
        setStats(statsResult.value);
      } else {
        setStats(EMPTY_DASHBOARD_STATS);
      }
      setCharts(chartsResult.status === "fulfilled" ? chartsResult.value : null);
      setActivities(activitiesResult.status === "fulfilled" ? activitiesResult.value : []);
      setOnlineDrivers(driversResult.status === "fulfilled" ? driversResult.value : []);

      const firstError = [statsResult, chartsResult, activitiesResult, driversResult].find(
        (result) => result.status === "rejected"
      );
      if (firstError?.status === "rejected") {
        const reason = firstError.reason;
        toast.error(reason instanceof Error ? reason.message : "Failed to load dashboard data");
      }
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (isAuthenticated) {
      void load();
    }
  }, [isAuthenticated, load]);

  const displayValue = (value: string) => (isLoading ? "—" : value);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Dashboard"
        description="Welcome back! Here's what's happening with Bull Wave Rides today."
      />

      {isLoading ? (
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <Loader2 className="h-4 w-4 animate-spin" />
          Loading live dashboard data...
        </div>
      ) : null}

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Total Users"
          value={displayValue(formatNumber(stats.totalUsers))}
          change="Registered riders"
          changeType="neutral"
          icon={Users}
        />
        <StatCard
          title="Total Drivers"
          value={displayValue(formatNumber(stats.totalDrivers))}
          change="On platform"
          changeType="neutral"
          icon={Car}
        />
        <StatCard
          title="Active Drivers"
          value={displayValue(formatNumber(stats.activeDrivers))}
          change="Currently online"
          changeType="neutral"
          icon={UserCheck}
          iconColor="bg-success/15 text-success"
        />
        <StatCard
          title="Active Rides"
          value={displayValue(formatNumber(stats.activeRides))}
          change="Live now"
          changeType="neutral"
          icon={MapPin}
          iconColor="bg-primary/10 text-primary"
        />
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6">
        <StatCard
          title="Completed Rides"
          value={displayValue(formatNumber(stats.completedRides))}
          change="All time"
          changeType="neutral"
          icon={CheckCircle}
          iconColor="bg-success/15 text-success"
        />
        <StatCard
          title="Today's Revenue"
          value={displayValue(formatCurrency(stats.todayRevenue))}
          change="Ride fare collected"
          changeType="neutral"
          icon={IndianRupee}
        />
        <StatCard
          title="Total Revenue"
          value={displayValue(formatCurrency(stats.totalRevenue))}
          change="All completed rides"
          changeType="neutral"
          icon={TrendingUp}
        />
        <StatCard
          title="Driver Earnings Today"
          value={displayValue(formatCurrency(stats.driverEarningsToday))}
          change={`Per-vehicle commission (default ${stats.driverCommissionPercentage}%)`}
          changeType="neutral"
          icon={Wallet}
        />
        <StatCard
          title="Company Earnings Today"
          value={displayValue(formatCurrency(stats.companyEarningsToday))}
          change="Platform share today"
          changeType="neutral"
          icon={Building2}
        />
        <StatCard
          title="Total Commission Paid"
          value={displayValue(formatCurrency(stats.totalCommissionPaid))}
          change="Paid to drivers"
          changeType="neutral"
          icon={Percent}
        />
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-2">
        <StatCard
          title="Cancelled Rides"
          value={displayValue(formatNumber(stats.cancelledRides))}
          change="All time"
          changeType="neutral"
          icon={XCircle}
          iconColor="bg-destructive/15 text-destructive"
        />
        <StatCard
          title="Monthly Revenue"
          value={displayValue(formatCurrency(stats.monthlyRevenue))}
          change="This month"
          changeType="neutral"
          icon={IndianRupee}
        />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <RideBookingChart data={charts?.rideBooking ?? []} isLoading={isLoading} />
        <RevenueChart data={charts?.revenue ?? []} isLoading={isLoading} />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <UserGrowthChart data={charts?.userGrowth ?? []} isLoading={isLoading} />
        <DriverGrowthChart data={charts?.driverGrowth ?? []} isLoading={isLoading} />
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2">
          <LiveActivity activities={activities} isLoading={isLoading} />
        </div>
        <div className="space-y-6">
          <QuickActions />
          <OnlineDriversCard
            drivers={onlineDrivers}
            activeCount={stats.activeDrivers}
            isLoading={isLoading}
          />
        </div>
      </div>
    </div>
  );
}
