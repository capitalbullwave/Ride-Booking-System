import {
  Users,
  Car,
  UserCheck,
  MapPin,
  CheckCircle,
  XCircle,
  IndianRupee,
  TrendingUp,
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
import { dashboardStats } from "@/data/mock-data";
import { formatCurrency, formatNumber } from "@/lib/format";

export default function DashboardPage() {
  const stats = dashboardStats;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Dashboard"
        description="Welcome back! Here's what's happening with Fast Bull today."
      />

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Total Users"
          value={formatNumber(stats.totalUsers)}
          change="+12.5% from last month"
          changeType="positive"
          icon={Users}
        />
        <StatCard
          title="Total Drivers"
          value={formatNumber(stats.totalDrivers)}
          change="+8.2% from last month"
          changeType="positive"
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

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Completed Rides"
          value={formatNumber(stats.completedRides)}
          change="+15.3% this month"
          changeType="positive"
          icon={CheckCircle}
          iconColor="bg-success/15 text-success"
        />
        <StatCard
          title="Cancelled Rides"
          value={formatNumber(stats.cancelledRides)}
          change="-2.1% from last month"
          changeType="positive"
          icon={XCircle}
          iconColor="bg-destructive/15 text-destructive"
        />
        <StatCard
          title="Today's Revenue"
          value={formatCurrency(stats.todayRevenue)}
          change="+18.7% vs yesterday"
          changeType="positive"
          icon={IndianRupee}
        />
        <StatCard
          title="Monthly Revenue"
          value={formatCurrency(stats.monthlyRevenue)}
          change="+22.4% from last month"
          changeType="positive"
          icon={TrendingUp}
          iconColor="bg-secondary/25 text-secondary-foreground"
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
