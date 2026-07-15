"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { IndianRupee, TrendingUp, Wallet, Clock, ClipboardCheck, List } from "lucide-react";
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
import { formatCurrency, formatDateTime, capitalize } from "@/lib/format";
import {
  fetchFinanceActivity,
  fetchFinanceOverview,
  type FinanceActivity,
  type FinanceOverview,
} from "@/lib/finance-api";
import { useAuth } from "@/components/providers/auth-provider";
import { toast } from "sonner";

const financeLinks = [
  {
    title: "All Activity",
    href: "/finance/activity",
    desc: "Every user & driver money movement in one list",
    icon: List,
  },
  {
    title: "Approvals & Payments",
    href: "/finance/approvals",
    desc: "Pay withdrawals and approve refunds from here",
    icon: ClipboardCheck,
  },
  {
    title: "Commission Reports",
    href: "/finance/commission",
    desc: "Platform commission by month",
    icon: TrendingUp,
  },
];

const emptyOverview: FinanceOverview = {
  totalRevenue: 0,
  platformCommission: 0,
  driverEarnings: 0,
  pendingPayouts: 0,
  pendingPayoutCount: 0,
  pendingApprovalsCount: 0,
  pendingWithdrawalRequests: 0,
  pendingRefundRequests: 0,
  revenueChange: "Loading…",
  revenueChangeType: "neutral",
  platformFeePercent: 0,
  driverSharePercent: 0,
  thisMonthRevenue: 0,
  thisMonthCommission: 0,
};

export default function FinancePage() {
  const { isAuthenticated, isLoading: authLoading } = useAuth();
  const [overview, setOverview] = useState<FinanceOverview>(emptyOverview);
  const [recent, setRecent] = useState<FinanceActivity[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [ov, tx] = await Promise.all([
        fetchFinanceOverview(),
        fetchFinanceActivity({ limit: 8 }),
      ]);
      setOverview(ov);
      setRecent(tx.items);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Failed to load finance data");
      setOverview(emptyOverview);
      setRecent([]);
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
      <PageHeader
        title="Finance"
        description="Single place for user & driver money — activity, approvals, and payouts"
      />

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Total Revenue"
          value={loading ? "…" : formatCurrency(overview.totalRevenue)}
          change={overview.revenueChange}
          changeType={overview.revenueChangeType}
          icon={IndianRupee}
        />
        <StatCard
          title="Platform Commission"
          value={loading ? "…" : formatCurrency(overview.platformCommission)}
          change={`${overview.platformFeePercent}% of fare`}
          changeType="neutral"
          icon={TrendingUp}
          iconColor="bg-secondary/10 text-secondary"
        />
        <StatCard
          title="Driver Earnings"
          value={loading ? "…" : formatCurrency(overview.driverEarnings)}
          change={`${overview.driverSharePercent}% share`}
          changeType="neutral"
          icon={Wallet}
          iconColor="bg-emerald-100 text-emerald-600"
        />
        <StatCard
          title="Needs your action"
          value={loading ? "…" : String(overview.pendingApprovalsCount)}
          change={
            overview.pendingApprovalsCount > 0
              ? `${overview.pendingWithdrawalRequests} payouts · ${overview.pendingRefundRequests} refunds`
              : "Nothing pending"
          }
          changeType={overview.pendingApprovalsCount > 0 ? "negative" : "neutral"}
          icon={Clock}
          iconColor="bg-amber-100 text-amber-600"
        />
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {financeLinks.map((link) => (
          <Link key={link.href} href={link.href}>
            <Card className="h-full cursor-pointer transition-shadow hover:shadow-md">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-base">
                  <link.icon className="h-4 w-4 text-primary" />
                  {link.title}
                </CardTitle>
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
          <CardTitle>Recent activity</CardTitle>
          <div className="flex gap-2">
            <ButtonLink variant="outline" size="sm" href="/finance/approvals">
              Approvals
            </ButtonLink>
            <ButtonLink variant="outline" size="sm" href="/finance/activity">
              View all
            </ButtonLink>
          </div>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Party</TableHead>
                <TableHead>Name</TableHead>
                <TableHead>Activity</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Date</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {recent.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="py-8 text-center text-muted-foreground">
                    {loading ? "Loading…" : "No activity yet"}
                  </TableCell>
                </TableRow>
              ) : (
                recent.map((tx) => (
                  <TableRow key={tx.id}>
                    <TableCell>{capitalize(tx.party)}</TableCell>
                    <TableCell>{tx.partyName}</TableCell>
                    <TableCell>{tx.title}</TableCell>
                    <TableCell className="font-medium">{formatCurrency(tx.amount)}</TableCell>
                    <TableCell>
                      <StatusBadge status={tx.status === "paid" ? "completed" : tx.status} />
                    </TableCell>
                    <TableCell>{tx.date ? formatDateTime(tx.date) : "—"}</TableCell>
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
