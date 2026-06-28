"use client";

import { FileText, Download } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  RideBookingChart,
  RevenueChart,
  UserGrowthChart,
  DriverGrowthChart,
} from "@/components/dashboard/charts";
import { toast } from "sonner";

const reports = [
  { id: "daily-rides", title: "Daily Ride Report", description: "Ride bookings, completions, and cancellations for today" },
  { id: "monthly-rides", title: "Monthly Ride Report", description: "Comprehensive monthly ride analytics" },
  { id: "driver-performance", title: "Driver Performance Report", description: "Driver ratings, trips, and earnings analysis" },
  { id: "revenue", title: "Revenue Report", description: "Revenue breakdown by vehicle type and region" },
  { id: "cancellation", title: "Cancellation Report", description: "Cancellation trends and reasons analysis" },
  { id: "user-growth", title: "User Growth Report", description: "User acquisition and retention metrics" },
];

export default function ReportsPage() {
  const handleExport = (format: string, report: string) => {
    toast.success(`${report} exported as ${format}`);
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Reports & Analytics" description="Generate and export business reports" />

      <Tabs defaultValue="overview">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="rides">Rides</TabsTrigger>
          <TabsTrigger value="revenue">Revenue</TabsTrigger>
          <TabsTrigger value="users">Users</TabsTrigger>
          <TabsTrigger value="drivers">Drivers</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="mt-6 space-y-6">
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {reports.map((report) => (
              <Card key={report.id}>
                <CardHeader>
                  <div className="flex items-start gap-3">
                    <div className="rounded-lg bg-primary/10 p-2">
                      <FileText className="h-5 w-5 text-primary" />
                    </div>
                    <div>
                      <CardTitle className="text-base">{report.title}</CardTitle>
                      <CardDescription className="mt-1">{report.description}</CardDescription>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="flex gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    className="flex-1"
                    onClick={() => handleExport("PDF", report.title)}
                  >
                    <Download className="mr-2 h-4 w-4" /> PDF
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    className="flex-1"
                    onClick={() => handleExport("Excel", report.title)}
                  >
                    <Download className="mr-2 h-4 w-4" /> Excel
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        </TabsContent>

        <TabsContent value="rides" className="mt-6">
          <RideBookingChart />
        </TabsContent>
        <TabsContent value="revenue" className="mt-6">
          <RevenueChart />
        </TabsContent>
        <TabsContent value="users" className="mt-6">
          <UserGrowthChart />
        </TabsContent>
        <TabsContent value="drivers" className="mt-6">
          <DriverGrowthChart />
        </TabsContent>
      </Tabs>
    </div>
  );
}
