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
import { users } from "@/data/mock-data";
import { formatCurrency, formatDate } from "@/lib/format";

const walletTxns = users.flatMap((u, i) => [
  { id: `WLT-${i}A`, user: u.name, type: "credit", amount: 500, desc: "Wallet top-up", status: "completed", date: "2025-06-22" },
  { id: `WLT-${i}B`, user: u.name, type: "debit", amount: 145, desc: "Ride payment", status: "completed", date: "2025-06-21" },
]).slice(0, 10);

export default function WalletPage() {
  return (
    <div className="space-y-6">
      <PageHeader title="Wallet Transactions" description="User wallet activity and balances">
        <ExportButton filename="wallet-transactions" />
      </PageHeader>
      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>ID</TableHead>
                <TableHead>User</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Description</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Date</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {walletTxns.map((tx) => (
                <TableRow key={tx.id}>
                  <TableCell className="font-mono text-xs">{tx.id}</TableCell>
                  <TableCell>{tx.user}</TableCell>
                  <TableCell>
                    <StatusBadge status={tx.type === "credit" ? "completed" : "cancelled"} />
                  </TableCell>
                  <TableCell>{tx.desc}</TableCell>
                  <TableCell className={tx.type === "credit" ? "text-emerald-600" : "text-red-600"}>
                    {tx.type === "credit" ? "+" : "-"}{formatCurrency(tx.amount)}
                  </TableCell>
                  <TableCell><StatusBadge status={tx.status} /></TableCell>
                  <TableCell>{formatDate(tx.date)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
