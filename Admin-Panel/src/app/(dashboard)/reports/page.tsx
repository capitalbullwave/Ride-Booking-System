"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { FileText, Download, BarChart3, CheckCircle, MapPin, XCircle } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { StatCard } from "@/components/shared/stat-card";
import {
  RideBookingChart,
  RevenueChart,
  UserGrowthChart,
  DriverGrowthChart,
} from "@/components/dashboard/charts";
import { useDashboardCharts } from "@/hooks/use-dashboard-charts";
import { formatCurrency } from "@/lib/format";
import {
  fetchCorporateReports,
  listCorporateCompanies,
  type CorporateCompany,
} from "@/lib/corporate-api";
import { toast } from "sonner";

const reports = [
  { id: "daily-rides", title: "Daily Ride Report", description: "Ride bookings, completions, and cancellations for today" },
  { id: "monthly-rides", title: "Monthly Ride Report", description: "Comprehensive monthly ride analytics" },
  { id: "driver-performance", title: "Driver Performance Report", description: "Driver ratings, trips, and earnings analysis" },
  { id: "revenue", title: "Revenue Report", description: "Revenue breakdown by vehicle type and region" },
  { id: "cancellation", title: "Cancellation Report", description: "Cancellation trends and reasons analysis" },
  { id: "user-growth", title: "User Growth Report", description: "User acquisition and retention metrics" },
];

const TAB_VALUES = new Set(["overview", "rides", "revenue", "users", "drivers", "corporate"]);

export default function ReportsPage() {
  const searchParams = useSearchParams();
  const { charts, isLoading } = useDashboardCharts();
  const initialTab = useMemo(() => {
    const tab = searchParams.get("tab") ?? "overview";
    return TAB_VALUES.has(tab) ? tab : "overview";
  }, [searchParams]);
  const [tab, setTab] = useState(initialTab);

  const [companies, setCompanies] = useState<CorporateCompany[]>([]);
  const [companyId, setCompanyId] = useState("all");
  const [fromDate, setFromDate] = useState("");
  const [toDate, setToDate] = useState("");
  const [report, setReport] = useState<{
    ride_count: number;
    completed_rides: number;
    cancelled_rides: number;
    monthly_spending: number;
  } | null>(null);

  useEffect(() => {
    setTab(initialTab);
  }, [initialTab]);

  useEffect(() => {
    void listCorporateCompanies({ limit: 100 }).then((d) => setCompanies(d.items)).catch(() => {
      setCompanies([]);
    });
  }, []);

  const loadCorporate = useCallback(async () => {
    try {
      const data = await fetchCorporateReports({
        company_id: companyId === "all" ? undefined : companyId,
        from_date: fromDate || undefined,
        to_date: toDate || undefined,
      });
      setReport(data);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to load corporate report");
    }
  }, [companyId, fromDate, toDate]);

  useEffect(() => {
    if (tab === "corporate") {
      void loadCorporate();
    }
  }, [tab, loadCorporate]);

  const handleExport = (format: string, reportTitle: string) => {
    toast.success(`${reportTitle} exported as ${format}`);
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Reports & Analytics" description="Generate and export business reports" />

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="rides">Rides</TabsTrigger>
          <TabsTrigger value="revenue">Revenue</TabsTrigger>
          <TabsTrigger value="users">Users</TabsTrigger>
          <TabsTrigger value="drivers">Drivers</TabsTrigger>
          <TabsTrigger value="corporate">Corporate</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="mt-6 space-y-6">
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {reports.map((item) => (
              <Card key={item.id}>
                <CardHeader>
                  <div className="flex items-start gap-3">
                    <div className="rounded-lg bg-primary/10 p-2">
                      <FileText className="h-5 w-5 text-primary" />
                    </div>
                    <div>
                      <CardTitle className="text-base">{item.title}</CardTitle>
                      <CardDescription className="mt-1">{item.description}</CardDescription>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="flex gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    className="flex-1"
                    onClick={() => handleExport("PDF", item.title)}
                  >
                    <Download className="mr-2 h-4 w-4" /> PDF
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    className="flex-1"
                    onClick={() => handleExport("Excel", item.title)}
                  >
                    <Download className="mr-2 h-4 w-4" /> Excel
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        </TabsContent>

        <TabsContent value="rides" className="mt-6">
          <RideBookingChart data={charts?.rideBooking ?? []} isLoading={isLoading} />
        </TabsContent>
        <TabsContent value="revenue" className="mt-6">
          <RevenueChart data={charts?.revenue ?? []} isLoading={isLoading} />
        </TabsContent>
        <TabsContent value="users" className="mt-6">
          <UserGrowthChart data={charts?.userGrowth ?? []} isLoading={isLoading} />
        </TabsContent>
        <TabsContent value="drivers" className="mt-6">
          <DriverGrowthChart data={charts?.driverGrowth ?? []} isLoading={isLoading} />
        </TabsContent>

        <TabsContent value="corporate" className="mt-6 space-y-6">
          <Card>
            <CardContent className="flex flex-wrap items-end gap-4 pt-6">
              <div className="space-y-2">
                <Label>Company</Label>
                <Select value={companyId} onValueChange={(v) => setCompanyId(v ?? "all")}>
                  <SelectTrigger className="w-[240px]">
                    <SelectValue placeholder="Company" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All companies</SelectItem>
                    {companies.map((c) => (
                      <SelectItem key={c.id} value={c.id}>
                        {c.company_name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>From</Label>
                <Input type="date" value={fromDate} onChange={(e) => setFromDate(e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>To</Label>
                <Input type="date" value={toDate} onChange={(e) => setToDate(e.target.value)} />
              </div>
              <Button onClick={() => void loadCorporate()}>Refresh</Button>
            </CardContent>
          </Card>

          {report ? (
            <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
              <StatCard title="Ride Count" value={report.ride_count} icon={MapPin} />
              <StatCard title="Completed" value={report.completed_rides} icon={CheckCircle} />
              <StatCard title="Cancelled" value={report.cancelled_rides} icon={XCircle} />
              <StatCard
                title="Spending"
                value={formatCurrency(report.monthly_spending)}
                icon={BarChart3}
              />
            </div>
          ) : (
            <p className="text-sm text-muted-foreground">Loading corporate report…</p>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}
