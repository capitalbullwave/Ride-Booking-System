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
import {
  rideBookingChartData,
  revenueChartData,
  userGrowthChartData,
  driverGrowthChartData,
} from "@/data/mock-data";

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

export function RideBookingChart() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Ride Bookings</CardTitle>
        <CardDescription>Weekly ride booking trends</CardDescription>
      </CardHeader>
      <CardContent>
        <ChartContainer config={ridesConfig} className="h-[300px] w-full">
          <BarChart data={rideBookingChartData}>
            <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
            <XAxis dataKey="name" />
            <YAxis />
            <ChartTooltip content={<ChartTooltipContent />} />
            <Bar dataKey="rides" fill="var(--color-rides)" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ChartContainer>
      </CardContent>
    </Card>
  );
}

export function RevenueChart() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Revenue</CardTitle>
        <CardDescription>Monthly revenue overview (₹)</CardDescription>
      </CardHeader>
      <CardContent>
        <ChartContainer config={revenueConfig} className="h-[300px] w-full">
          <AreaChart data={revenueChartData}>
            <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
            <XAxis dataKey="name" />
            <YAxis tickFormatter={(v) => `${(v / 10000000).toFixed(1)}Cr`} />
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
      </CardContent>
    </Card>
  );
}

export function UserGrowthChart() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>User Growth</CardTitle>
        <CardDescription>Monthly user registrations</CardDescription>
      </CardHeader>
      <CardContent>
        <ChartContainer config={usersConfig} className="h-[300px] w-full">
          <LineChart data={userGrowthChartData}>
            <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
            <XAxis dataKey="name" />
            <YAxis tickFormatter={(v) => `${(v / 1000).toFixed(0)}K`} />
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
      </CardContent>
    </Card>
  );
}

export function DriverGrowthChart() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Driver Growth</CardTitle>
        <CardDescription>Monthly driver onboarding</CardDescription>
      </CardHeader>
      <CardContent>
        <ChartContainer config={driversConfig} className="h-[300px] w-full">
          <LineChart data={driverGrowthChartData}>
            <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
            <XAxis dataKey="name" />
            <YAxis tickFormatter={(v) => `${(v / 1000).toFixed(0)}K`} />
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
      </CardContent>
    </Card>
  );
}
