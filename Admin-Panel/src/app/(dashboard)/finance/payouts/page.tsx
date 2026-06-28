"use client";

import { PageHeader } from "@/components/layout/page-header";
import { ExportButton } from "@/components/shared/export-button";
import { StatusBadge } from "@/components/shared/status-badge";
import { Card, CardContent } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { drivers } from "@/data/mock-data";
import { formatCurrency, formatDate } from "@/lib/format";

const payouts = drivers.slice(0, 6).map((d, i) => ({
  id: `PAY-${String(i + 1).padStart(3, "0")}`,
  driverId: d.id,
  driverName: d.name,
  amount: Math.round(d.walletBalance * 0.8),
  status: i % 3 === 0 ? "pending" : "completed",
  date: "2025-06-23",
  method: "Bank Transfer",
}));

export default function PayoutsPage() {
  return (
    <div className="space-y-6">
      <PageHeader title="Driver Payouts" description="Manage weekly driver settlements">
        <ExportButton filename="driver-payouts" label="Export" />
        <Button>Process All Pending</Button>
      </PageHeader>
      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Payout ID</TableHead>
                <TableHead>Driver</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Method</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {payouts.map((p) => (
                <TableRow key={p.id}>
                  <TableCell className="font-mono text-xs">{p.id}</TableCell>
                  <TableCell>{p.driverName}</TableCell>
                  <TableCell className="font-medium">{formatCurrency(p.amount)}</TableCell>
                  <TableCell>{p.method}</TableCell>
                  <TableCell><StatusBadge status={p.status} /></TableCell>
                  <TableCell>{formatDate(p.date)}</TableCell>
                  <TableCell>
                    {p.status === "pending" && (
                      <Button size="sm" variant="outline">Process</Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
