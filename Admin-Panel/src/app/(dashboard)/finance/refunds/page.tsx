"use client";

import { PageHeader } from "@/components/layout/page-header";
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
import { formatCurrency, formatDate } from "@/lib/format";

const refunds = [
  { id: "REF-001", rideId: "WG-2844", user: "Vikram Singh", amount: 450, reason: "Driver cancelled", status: "pending", date: "2025-06-23" },
  { id: "REF-002", rideId: "WG-2830", user: "Rajesh Kumar", amount: 120, reason: "Overcharged", status: "completed", date: "2025-06-22" },
  { id: "REF-003", rideId: "WG-2815", user: "Priya Sharma", amount: 280, reason: "Ride not completed", status: "pending", date: "2025-06-21" },
];

export default function RefundsPage() {
  return (
    <div className="space-y-6">
      <PageHeader title="Refund Requests" description="Review and process refund requests" />
      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Refund ID</TableHead>
                <TableHead>Ride ID</TableHead>
                <TableHead>User</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Reason</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {refunds.map((r) => (
                <TableRow key={r.id}>
                  <TableCell className="font-mono text-xs">{r.id}</TableCell>
                  <TableCell className="font-mono text-xs">{r.rideId}</TableCell>
                  <TableCell>{r.user}</TableCell>
                  <TableCell className="font-medium">{formatCurrency(r.amount)}</TableCell>
                  <TableCell>{r.reason}</TableCell>
                  <TableCell><StatusBadge status={r.status} /></TableCell>
                  <TableCell>{formatDate(r.date)}</TableCell>
                  <TableCell>
                    {r.status === "pending" && (
                      <div className="flex gap-1">
                        <Button size="sm">Approve</Button>
                        <Button size="sm" variant="destructive">Reject</Button>
                      </div>
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
