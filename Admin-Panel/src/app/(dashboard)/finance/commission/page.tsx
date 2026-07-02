"use client";

import { PageHeader } from "@/components/layout/page-header";
import { ExportButton } from "@/components/shared/export-button";
import { RevenueChart } from "@/components/dashboard/charts";
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

const commissionData = [
  { month: "January", revenue: 52000000, commission: 10400000, rides: 185000 },
  { month: "February", revenue: 48000000, commission: 9600000, rides: 172000 },
  { month: "March", revenue: 61000000, commission: 12200000, rides: 210000 },
  { month: "April", revenue: 55000000, commission: 11000000, rides: 195000 },
  { month: "May", revenue: 68000000, commission: 13600000, rides: 240000 },
  { month: "June", revenue: 72000000, commission: 14400000, rides: 255000 },
];

export default function CommissionPage() {
  return (
    <div className="space-y-6">
      <PageHeader title="Commission Reports" description="Platform commission analytics and settlement logs">
        <ExportButton filename="commission-report" label="Export Excel" />
      </PageHeader>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardHeader className="pb-2"><CardTitle className="text-sm font-medium text-muted-foreground">Total Commission (YTD)</CardTitle></CardHeader>
          <CardContent><p className="text-2xl font-bold">{formatCurrency(71200000)}</p></CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2"><CardTitle className="text-sm font-medium text-muted-foreground">Commission Rate</CardTitle></CardHeader>
          <CardContent><p className="text-2xl font-bold">20%</p></CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2"><CardTitle className="text-sm font-medium text-muted-foreground">This Month</CardTitle></CardHeader>
          <CardContent><p className="text-2xl font-bold">{formatCurrency(14400000)}</p></CardContent>
        </Card>
      </div>

      <RevenueChart />

      <Card>
        <CardHeader><CardTitle>Settlement Logs</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Month</TableHead>
                <TableHead>Total Revenue</TableHead>
                <TableHead>Commission (20%)</TableHead>
                <TableHead>Total Rides</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {commissionData.map((row) => (
                <TableRow key={row.month}>
                  <TableCell className="font-medium">{row.month}</TableCell>
                  <TableCell>{formatCurrency(row.revenue)}</TableCell>
                  <TableCell className="text-primary font-medium">{formatCurrency(row.commission)}</TableCell>
                  <TableCell>{row.rides.toLocaleString()}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
