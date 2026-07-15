"use client";

import { useCallback, useEffect, useState } from "react";
import { PageHeader } from "@/components/layout/page-header";
import { RevenueChart } from "@/components/dashboard/charts";
import { useDashboardCharts } from "@/hooks/use-dashboard-charts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { formatCurrency } from "@/lib/format";
import { fetchCommissionReport, type CommissionReport } from "@/lib/finance-api";
import { useAuth } from "@/components/providers/auth-provider";
import { toast } from "sonner";

const emptyReport: CommissionReport = {
  totalCommissionYtd: 0,
  commissionRate: 0,
  thisMonthCommission: 0,
  months: [],
};

export default function CommissionPage() {
  const { isAuthenticated, isLoading: authLoading } = useAuth();
  const { charts, isLoading: chartsLoading } = useDashboardCharts();
  const [report, setReport] = useState<CommissionReport>(emptyReport);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      setReport(await fetchCommissionReport());
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Failed to load commission report");
      setReport(emptyReport);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (authLoading) return;
    if (!isAuthenticated) {
      setLoading(false);
      return;
    }
    void load();
  }, [authLoading, isAuthenticated, load]);

  return (
    <div className="space-y-6">
      <PageHeader title="Commission Reports" description="Platform commission analytics and settlement logs" />

      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Total Commission
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">
              {loading ? "…" : formatCurrency(report.totalCommissionYtd)}
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Commission Rate
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">
              {loading ? "…" : `${report.commissionRate}%`}
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">This Month</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">
              {loading ? "…" : formatCurrency(report.thisMonthCommission)}
            </p>
          </CardContent>
        </Card>
      </div>

      <RevenueChart data={charts?.revenue ?? []} isLoading={chartsLoading} />

      <Card>
        <CardHeader>
          <CardTitle>Settlement Logs</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Month</TableHead>
                <TableHead>Total Revenue</TableHead>
                <TableHead>Commission</TableHead>
                <TableHead>Total Rides</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {report.months.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={4} className="text-center text-muted-foreground py-8">
                    {loading ? "Loading…" : "No completed rides yet"}
                  </TableCell>
                </TableRow>
              ) : (
                report.months.map((row) => (
                  <TableRow key={`${row.year}-${row.month}`}>
                    <TableCell className="font-medium">
                      {row.month} {row.year}
                    </TableCell>
                    <TableCell>{formatCurrency(row.revenue)}</TableCell>
                    <TableCell className="text-primary font-medium">
                      {formatCurrency(row.commission)}
                    </TableCell>
                    <TableCell>{row.rides.toLocaleString()}</TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
