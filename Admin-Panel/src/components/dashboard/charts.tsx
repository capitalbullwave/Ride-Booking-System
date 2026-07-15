"use client";

import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Line,
  LineChart,
  XAxis,
  YAxis,
} from "recharts";
import { Loader2 } from "lucide-react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  ChartConfig,
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart";
import type { ChartDataPoint } from "@/types";

const ridesConfig = {
  rides: { label: "Rides", color: "var(--chart-1)" },
} satisfies ChartConfig;

const revenueConfig = {
  revenue: { label: "Revenue", color: "var(--chart-2)" },
} satisfies ChartConfig;

const usersConfig = {
  users: { label: "Users", color: "var(--chart-3)" },
} satisfies ChartConfig;

const driversConfig = {
  drivers: { label: "Drivers", color: "var(--chart-4)" },
} satisfies ChartConfig;

type ChartProps = {
  data: ChartDataPoint[];
  isLoading?: boolean;
};

function ChartLoadingState() {
  return (
    <div className="flex h-[300px] items-center justify-center text-sm text-muted-foreground">
      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
      Loading chart data...
    </div>
  );
}

function ChartEmptyState({ label }: { label: string }) {
  return (
    <div className="flex h-[300px] items-center justify-center text-sm text-muted-foreground">
      No {label} data yet
    </div>
  );
}

export function RideBookingChart({ data, isLoading = false }: ChartProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Ride Bookings</CardTitle>
        <CardDescription>Weekly ride booking trends</CardDescription>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <ChartLoadingState />
        ) : data.length === 0 ? (
          <ChartEmptyState label="ride booking" />
        ) : (
          <ChartContainer config={ridesConfig} className="h-[300px] w-full">
            <BarChart data={data}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
              <XAxis dataKey="name" />
              <YAxis allowDecimals={false} />
              <ChartTooltip content={<ChartTooltipContent />} />
              <Bar dataKey="rides" fill="var(--color-rides)" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ChartContainer>
        )}
      </CardContent>
    </Card>
  );
}

export function RevenueChart({ data, isLoading = false }: ChartProps) {
  const maxRevenue = Math.max(...data.map((point) => point.revenue ?? point.value ?? 0), 0);
  const useCroreScale = maxRevenue >= 10_000_000;

  return (
    <Card>
      <CardHeader>
        <CardTitle>Revenue</CardTitle>
        <CardDescription>Monthly revenue overview (₹)</CardDescription>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <ChartLoadingState />
        ) : data.length === 0 ? (
          <ChartEmptyState label="revenue" />
        ) : (
          <ChartContainer config={revenueConfig} className="h-[300px] w-full">
            <AreaChart data={data}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
              <XAxis dataKey="name" />
              <YAxis
                tickFormatter={(value) =>
                  useCroreScale ? `${(value / 10_000_000).toFixed(1)}Cr` : `₹${value}`
                }
              />
              <ChartTooltip content={<ChartTooltipContent />} />
              <Area
                type="monotone"
                dataKey="revenue"
                fill="var(--color-revenue)"
                fillOpacity={0.2}
                stroke="var(--color-revenue)"
                strokeWidth={2}
              />
            </AreaChart>
          </ChartContainer>
        )}
      </CardContent>
    </Card>
  );
}

export function UserGrowthChart({ data, isLoading = false }: ChartProps) {
  const maxUsers = Math.max(...data.map((point) => point.users ?? point.value ?? 0), 0);
  const useThousands = maxUsers >= 1000;

  return (
    <Card>
      <CardHeader>
        <CardTitle>User Growth</CardTitle>
        <CardDescription>Monthly user registrations</CardDescription>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <ChartLoadingState />
        ) : data.length === 0 ? (
          <ChartEmptyState label="user growth" />
        ) : (
          <ChartContainer config={usersConfig} className="h-[300px] w-full">
            <LineChart data={data}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
              <XAxis dataKey="name" />
              <YAxis
                allowDecimals={false}
                tickFormatter={(value) => (useThousands ? `${(value / 1000).toFixed(0)}K` : `${value}`)}
              />
              <ChartTooltip content={<ChartTooltipContent />} />
              <Line
                type="monotone"
                dataKey="users"
                stroke="var(--color-users)"
                strokeWidth={2}
                dot={{ fill: "var(--color-users)" }}
              />
            </LineChart>
          </ChartContainer>
        )}
      </CardContent>
    </Card>
  );
}

export function DriverGrowthChart({ data, isLoading = false }: ChartProps) {
  const maxDrivers = Math.max(...data.map((point) => point.drivers ?? point.value ?? 0), 0);
  const useThousands = maxDrivers >= 1000;

  return (
    <Card>
      <CardHeader>
        <CardTitle>Driver Growth</CardTitle>
        <CardDescription>Monthly driver onboarding</CardDescription>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <ChartLoadingState />
        ) : data.length === 0 ? (
          <ChartEmptyState label="driver growth" />
        ) : (
          <ChartContainer config={driversConfig} className="h-[300px] w-full">
            <LineChart data={data}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
              <XAxis dataKey="name" />
              <YAxis
                allowDecimals={false}
                tickFormatter={(value) => (useThousands ? `${(value / 1000).toFixed(0)}K` : `${value}`)}
              />
              <ChartTooltip content={<ChartTooltipContent />} />
              <Line
                type="monotone"
                dataKey="drivers"
                stroke="var(--color-drivers)"
                strokeWidth={2}
                dot={{ fill: "var(--color-drivers)" }}
              />
            </LineChart>
          </ChartContainer>
        )}
      </CardContent>
    </Card>
  );
}
