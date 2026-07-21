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
  Clock,
  Briefcase,
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
import {
  fetchCorporateDashboard,
  type CorporateDashboard,
} from "@/lib/corporate-api";
import { formatCurrency, formatDate, formatNumber } from "@/lib/format";
import type { ActivityItem, DashboardStats } from "@/types";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ButtonLink } from "@/components/ui/button-link";
import { toast } from "sonner";

export default function DashboardPage() {
  const { isAuthenticated } = useAuth();
  const [stats, setStats] = useState<DashboardStats>(EMPTY_DASHBOARD_STATS);
  const [charts, setCharts] = useState<DashboardCharts | null>(null);
  const [activities, setActivities] = useState<ActivityItem[]>([]);
  const [onlineDrivers, setOnlineDrivers] = useState<OnlineDriverItem[]>([]);
  const [corporate, setCorporate] = useState<CorporateDashboard | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const load = useCallback(async () => {
    setIsLoading(true);
    try {
      const [statsResult, chartsResult, activitiesResult, driversResult, corporateResult] =
        await Promise.allSettled([
          fetchDashboardStats(),
          fetchDashboardCharts(),
          fetchDashboardActivities(),
          fetchOnlineDrivers(),
          fetchCorporateDashboard(),
        ]);

      if (statsResult.status === "fulfilled") {
        setStats(statsResult.value);
      } else {
        setStats(EMPTY_DASHBOARD_STATS);
      }
      setCharts(chartsResult.status === "fulfilled" ? chartsResult.value : null);
      setActivities(activitiesResult.status === "fulfilled" ? activitiesResult.value : []);
      setOnlineDrivers(driversResult.status === "fulfilled" ? driversResult.value : []);
      setCorporate(corporateResult.status === "fulfilled" ? corporateResult.value : null);

      const firstError = [
        statsResult,
        chartsResult,
        activitiesResult,
        driversResult,
        corporateResult,
      ].find((result) => result.status === "rejected");
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
  const corpValue = (value: string | number) =>
    isLoading || !corporate ? "—" : typeof value === "number" ? formatNumber(value) : value;

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
          change="Registered users"
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

      <div className="space-y-4">
        <div className="flex items-center justify-between gap-3">
          <h2 className="text-lg font-semibold tracking-tight">Corporate</h2>
          <ButtonLink href="/corporate/companies" variant="outline" size="sm">
            Manage companies
          </ButtonLink>
        </div>
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          <StatCard
            title="Total Companies"
            value={corpValue(corporate?.total_companies ?? 0)}
            change="Registered"
            changeType="neutral"
            icon={Briefcase}
          />
          <StatCard
            title="Pending Companies"
            value={corpValue(corporate?.pending_companies ?? 0)}
            change="Awaiting approval"
            changeType="neutral"
            icon={Clock}
          />
          <StatCard
            title="Approved Companies"
            value={corpValue(corporate?.approved_companies ?? 0)}
            change="Active accounts"
            changeType="neutral"
            icon={CheckCircle}
            iconColor="bg-success/15 text-success"
          />
          <StatCard
            title="Active Employees"
            value={corpValue(corporate?.active_employees ?? 0)}
            change="Linked users"
            changeType="neutral"
            icon={Users}
          />
          <StatCard
            title="Today's Corporate Rides"
            value={corpValue(corporate?.today_corporate_rides ?? 0)}
            change="Booked today"
            changeType="neutral"
            icon={MapPin}
            iconColor="bg-primary/10 text-primary"
          />
          <StatCard
            title="Monthly Corporate Revenue"
            value={
              isLoading || !corporate
                ? "—"
                : formatCurrency(corporate.monthly_corporate_revenue)
            }
            change="This month"
            changeType="neutral"
            icon={IndianRupee}
          />
        </div>

        <div className="grid gap-4 lg:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle>Pending Approvals</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {!corporate || corporate.pending_approvals.length === 0 ? (
                <p className="text-sm text-muted-foreground">No pending companies.</p>
              ) : (
                corporate.pending_approvals.map((c) => (
                  <div
                    key={c.id}
                    className="flex items-center justify-between rounded-xl border px-3 py-2"
                  >
                    <div>
                      <p className="font-medium">{c.company_name}</p>
                      <p className="text-xs text-muted-foreground">
                        {c.contact_person} · {formatDate(c.created_at)}
                      </p>
                    </div>
                    <ButtonLink size="sm" variant="outline" href={`/corporate/companies/${c.id}`}>
                      Review
                    </ButtonLink>
                  </div>
                ))
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Top Companies</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {!corporate || corporate.top_companies.length === 0 ? (
                <p className="text-sm text-muted-foreground">No spend data yet.</p>
              ) : (
                corporate.top_companies.map((c) => (
                  <div key={c.company_id} className="flex justify-between text-sm">
                    <span className="font-medium">{c.company_name}</span>
                    <span className="text-muted-foreground">
                      {c.ride_count} rides · {formatCurrency(c.spend)}
                    </span>
                  </div>
                ))
              )}
            </CardContent>
          </Card>
        </div>
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
