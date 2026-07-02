import Link from "next/link";
import { IndianRupee, TrendingUp, Wallet, Clock } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatCard } from "@/components/shared/stat-card";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ButtonLink } from "@/components/ui/button-link";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { StatusBadge } from "@/components/shared/status-badge";
import { transactions } from "@/data/mock-data";
import { formatCurrency, formatDateTime, capitalize } from "@/lib/format";

const financeLinks = [
  { title: "Transactions", href: "/finance/transactions", desc: "All payment transactions" },
  { title: "Driver Payouts", href: "/finance/payouts", desc: "Manage driver settlements" },
  { title: "Refund Requests", href: "/finance/refunds", desc: "Process refund requests" },
  { title: "Wallet Transactions", href: "/finance/wallet", desc: "User wallet activity" },
  { title: "Commission Reports", href: "/finance/commission", desc: "Platform commission analytics" },
];

export default function FinancePage() {
  const recentTransactions = transactions.slice(0, 5);

  return (
    <div className="space-y-6">
      <PageHeader title="Finance Dashboard" description="Revenue, payouts, and financial overview" />

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard title="Total Revenue" value={formatCurrency(68450000)} change="+22.4% this month" changeType="positive" icon={IndianRupee} />
        <StatCard title="Platform Commission" value={formatCurrency(13690000)} change="20% of revenue" changeType="neutral" icon={TrendingUp} iconColor="bg-secondary/10 text-secondary" />
        <StatCard title="Driver Earnings" value={formatCurrency(54760000)} change="80% share" changeType="neutral" icon={Wallet} iconColor="bg-emerald-100 text-emerald-600" />
        <StatCard title="Pending Payouts" value={formatCurrency(2450000)} change="156 drivers" changeType="neutral" icon={Clock} iconColor="bg-amber-100 text-amber-600" />
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {financeLinks.map((link) => (
          <Link key={link.href} href={link.href}>
            <Card className="transition-shadow hover:shadow-md cursor-pointer h-full">
              <CardHeader>
                <CardTitle className="text-base">{link.title}</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground">{link.desc}</p>
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Recent Transactions</CardTitle>
          <ButtonLink variant="outline" size="sm" href="/finance/transactions">
            View All
          </ButtonLink>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>ID</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Description</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Date</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {recentTransactions.map((tx) => (
                <TableRow key={tx.id}>
                  <TableCell className="font-mono text-xs">{tx.id}</TableCell>
                  <TableCell>{capitalize(tx.type)}</TableCell>
                  <TableCell>{tx.description}</TableCell>
                  <TableCell className="font-medium">{formatCurrency(tx.amount)}</TableCell>
                  <TableCell><StatusBadge status={tx.status} /></TableCell>
                  <TableCell>{formatDateTime(tx.date)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
