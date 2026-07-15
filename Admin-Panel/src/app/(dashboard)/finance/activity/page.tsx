"use client";

import { useCallback, useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { formatCurrency, formatDateTime, capitalize } from "@/lib/format";
import { fetchFinanceActivity, type FinanceActivity } from "@/lib/finance-api";
import { useAuth } from "@/components/providers/auth-provider";
import { toast } from "sonner";

export default function FinanceActivityPage() {
  const searchParams = useSearchParams();
  const initialParty = searchParams.get("party") || "all";
  const initialCategory = searchParams.get("category") || "all";
  const { isAuthenticated, isLoading: authLoading } = useAuth();
  const [items, setItems] = useState<FinanceActivity[]>([]);
  const [loading, setLoading] = useState(true);
  const [party, setParty] = useState(initialParty);
  const [category, setCategory] = useState(initialCategory);
  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetchFinanceActivity({ party, category, limit: 150 });
      setItems(res.items);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Failed to load activity");
      setItems([]);
    } finally {
      setLoading(false);
    }
  }, [party, category]);

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
        title="All Financial Activity"
        description="User and driver — wallet, rides, earnings, payouts, refunds, referrals"
      />

      <div className="flex flex-wrap gap-3">
        <Select value={party} onValueChange={setParty}>
          <SelectTrigger className="w-[160px]">
            <SelectValue placeholder="Party" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All parties</SelectItem>
            <SelectItem value="user">Users only</SelectItem>
            <SelectItem value="driver">Drivers only</SelectItem>
          </SelectContent>
        </Select>
        <Select value={category} onValueChange={setCategory}>
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Category" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All types</SelectItem>
            <SelectItem value="wallet">Wallet</SelectItem>
            <SelectItem value="earning">Driver earnings</SelectItem>
            <SelectItem value="payment">Ride payments</SelectItem>
            <SelectItem value="payout">Payouts / withdrawals</SelectItem>
            <SelectItem value="refund">Refunds</SelectItem>
            <SelectItem value="referral">Referrals</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>When</TableHead>
                <TableHead>Party</TableHead>
                <TableHead>Name</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>Activity</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {items.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center text-muted-foreground py-8">
                    {loading ? "Loading activity…" : "No financial activity yet"}
                  </TableCell>
                </TableRow>
              ) : (
                items.map((row) => (
                  <TableRow key={row.id}>
                    <TableCell className="whitespace-nowrap text-sm">
                      {row.date ? formatDateTime(row.date) : "—"}
                    </TableCell>
                    <TableCell>
                      <span className="rounded-md bg-muted px-2 py-0.5 text-xs font-medium">
                        {capitalize(row.party)}
                      </span>
                    </TableCell>
                    <TableCell>{row.partyName}</TableCell>
                    <TableCell>{capitalize(row.category)}</TableCell>
                    <TableCell>
                      <div className="max-w-md">
                        <p className="text-sm">{row.title}</p>
                        {row.reference ? (
                          <p className="font-mono text-xs text-muted-foreground">{row.reference}</p>
                        ) : null}
                      </div>
                    </TableCell>
                    <TableCell className="font-medium">{formatCurrency(row.amount)}</TableCell>
                    <TableCell>
                      <StatusBadge
                        status={row.status === "paid" ? "completed" : row.status}
                      />
                    </TableCell>
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
