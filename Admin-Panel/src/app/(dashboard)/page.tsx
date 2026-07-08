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
import { fetchDashboardStats } from "@/lib/dashboard-api";
import { formatCurrency, formatNumber } from "@/lib/format";
import type { DashboardStats } from "@/types";
import { dashboardStats as fallbackStats } from "@/data/mock-data";

export default function DashboardPage() {
  const { isAuthenticated } = useAuth();
  const [stats, setStats] = useState<DashboardStats>(fallbackStats);

  const load = useCallback(async () => {
    try {
      const data = await fetchDashboardStats();
      setStats(data);
    } catch {
      setStats(fallbackStats);
    }
  }, []);

  useEffect(() => {
    if (isAuthenticated) {
      void load();
    }
  }, [isAuthenticated, load]);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Dashboard"
        description="Welcome back! Here's what's happening with Bull Wave Rides today."
      />

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Total Users"
          value={formatNumber(stats.totalUsers)}
          change="Registered riders"
          changeType="neutral"
          icon={Users}
        />
        <StatCard
          title="Total Drivers"
          value={formatNumber(stats.totalDrivers)}
          change="On platform"
          changeType="neutral"
          icon={Car}
        />
        <StatCard
          title="Active Drivers"
          value={formatNumber(stats.activeDrivers)}
          change="Currently online"
          changeType="neutral"
          icon={UserCheck}
          iconColor="bg-success/15 text-success"
        />
        <StatCard
          title="Active Rides"
          value={formatNumber(stats.activeRides)}
          change="Live now"
          changeType="neutral"
          icon={MapPin}
          iconColor="bg-primary/10 text-primary"
        />
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6">
        <StatCard
          title="Completed Rides"
          value={formatNumber(stats.completedRides)}
          change="All time"
          changeType="neutral"
          icon={CheckCircle}
          iconColor="bg-success/15 text-success"
        />
        <StatCard
          title="Today's Revenue"
          value={formatCurrency(stats.todayRevenue)}
          change="Ride fare collected"
          changeType="neutral"
          icon={IndianRupee}
        />
        <StatCard
          title="Total Revenue"
          value={formatCurrency(stats.totalRevenue)}
          change="All completed rides"
          changeType="neutral"
          icon={TrendingUp}
        />
        <StatCard
          title="Driver Earnings Today"
          value={formatCurrency(stats.driverEarningsToday)}
          change={`Per-vehicle commission (default ${stats.driverCommissionPercentage}%)`}
          changeType="neutral"
          icon={Wallet}
        />
        <StatCard
          title="Company Earnings Today"
          value={formatCurrency(stats.companyEarningsToday)}
          change="Platform share today"
          changeType="neutral"
          icon={Building2}
        />
        <StatCard
          title="Total Commission Paid"
          value={formatCurrency(stats.totalCommissionPaid)}
          change="Paid to drivers"
          changeType="neutral"
          icon={Percent}
        />
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-2">
        <StatCard
          title="Cancelled Rides"
          value={formatNumber(stats.cancelledRides)}
          change="All time"
          changeType="neutral"
          icon={XCircle}
          iconColor="bg-destructive/15 text-destructive"
        />
        <StatCard
          title="Monthly Revenue"
          value={formatCurrency(stats.monthlyRevenue)}
          change="This month"
          changeType="neutral"
          icon={IndianRupee}
        />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <RideBookingChart />
        <RevenueChart />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <UserGrowthChart />
        <DriverGrowthChart />
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2">
          <LiveActivity />
        </div>
        <div className="space-y-6">
          <QuickActions />
          <OnlineDriversCard />
        </div>
      </div>
    </div>
  );
}
