"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { PageHeader } from "@/components/layout/page-header";
import { StatusBadge } from "@/components/shared/status-badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { formatCurrency, formatDateTime } from "@/lib/format";
import {
  approveFinanceRefund,
  fetchFinanceApprovals,
  processAllFinancePayouts,
  processFinancePayout,
  rejectFinancePayout,
  rejectFinanceRefund,
  type FinanceApprovals,
  type FinancePayout,
} from "@/lib/finance-api";
import { useAuth } from "@/components/providers/auth-provider";
import { toast } from "sonner";

const empty: FinanceApprovals = {
  payouts: [],
  refunds: [],
  history: [],
  paidCount: 0,
  rejectedCount: 0,
  pendingPayouts: 0,
  pendingRefunds: 0,
  totalPending: 0,
};

type HistoryFilter = "all" | "paid" | "rejected";

export default function FinanceApprovalsPage() {
  const { isAuthenticated, isLoading: authLoading } = useAuth();
  const [data, setData] = useState<FinanceApprovals>(empty);
  const [loading, setLoading] = useState(true);
  const [busyId, setBusyId] = useState<string | null>(null);
  const [historyFilter, setHistoryFilter] = useState<HistoryFilter>("all");
  const [selected, setSelected] = useState<FinancePayout | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      setData(await fetchFinanceApprovals());
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Failed to load approvals");
      setData(empty);
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

  async function run(id: string, action: () => Promise<void>, ok: string) {
    setBusyId(id);
    try {
      await action();
      toast.success(ok);
      await load();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Action failed");
    } finally {
      setBusyId(null);
    }
  }

  const filteredHistory = useMemo(() => {
    if (historyFilter === "paid") {
      return data.history.filter((h) => h.status === "paid");
    }
    if (historyFilter === "rejected") {
      return data.history.filter((h) => h.status === "rejected");
    }
    return data.history;
  }, [data.history, historyFilter]);

  const isRejected = selected?.status === "rejected";

  return (
    <div className="space-y-6">
      <PageHeader
        title="Approvals & Payments"
        description="Pay driver withdrawals and approve user refunds — all money actions happen here"
      >
        <Button
          onClick={() =>
            void run(
              "all",
              async () => {
                const res = await processAllFinancePayouts();
                if (res.failed) throw new Error(`Paid ${res.processed}, failed ${res.failed}`);
              },
              "All pending payouts paid",
            )
          }
          disabled={data.pendingPayouts === 0 || busyId === "all"}
        >
          Pay all pending payouts
        </Button>
      </PageHeader>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-muted-foreground">Total pending</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">{loading ? "…" : data.totalPending}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-muted-foreground">Withdrawals</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">{loading ? "…" : data.pendingPayouts}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-muted-foreground">User refunds</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">{loading ? "…" : data.pendingRefunds}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-muted-foreground">Paid</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">{loading ? "…" : data.paidCount}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-muted-foreground">Rejected</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">{loading ? "…" : data.rejectedCount}</p>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Withdrawals — Pay (users & drivers)</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Party</TableHead>
                <TableHead>Name</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Method</TableHead>
                <TableHead>Requested</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.payouts.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center text-muted-foreground py-8">
                    {loading ? "Loading…" : "No pending withdrawals"}
                  </TableCell>
                </TableRow>
              ) : (
                data.payouts.map((p) => (
                  <TableRow
                    key={p.id}
                    className="cursor-pointer"
                    onClick={() => setSelected(p)}
                  >
                    <TableCell>
                      <span className="rounded-md bg-muted px-2 py-0.5 text-xs font-medium capitalize">
                        {p.party ?? "driver"}
                      </span>
                    </TableCell>
                    <TableCell>{p.partyName ?? p.driverName ?? p.userName ?? "—"}</TableCell>
                    <TableCell className="font-medium">{formatCurrency(p.amount)}</TableCell>
                    <TableCell>{p.method}</TableCell>
                    <TableCell>
                      {p.createdAt
                        ? formatDateTime(p.createdAt)
                        : p.date
                          ? formatDateTime(p.date)
                          : "—"}
                    </TableCell>
                    <TableCell>
                      <StatusBadge status={p.status} />
                    </TableCell>
                    <TableCell onClick={(e) => e.stopPropagation()}>
                      <div className="flex gap-1">
                        <Button
                          size="sm"
                          disabled={busyId === p.id}
                          onClick={() =>
                            void run(p.id, () => processFinancePayout(p.id), "Payout paid")
                          }
                        >
                          Pay
                        </Button>
                        <Button
                          size="sm"
                          variant="destructive"
                          disabled={busyId === p.id}
                          onClick={() =>
                            void run(
                              p.id,
                              () => rejectFinancePayout(p.id, "Rejected by admin"),
                              "Payout rejected",
                            )
                          }
                        >
                          Reject
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>User refunds — Approve</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>User</TableHead>
                <TableHead>Ride</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Reason</TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.refunds.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center text-muted-foreground py-8">
                    {loading ? "Loading…" : "No pending refunds"}
                  </TableCell>
                </TableRow>
              ) : (
                data.refunds.map((r) => (
                  <TableRow key={r.id}>
                    <TableCell>{r.user}</TableCell>
                    <TableCell className="font-mono text-xs">{r.rideId}</TableCell>
                    <TableCell className="font-medium">{formatCurrency(r.amount)}</TableCell>
                    <TableCell className="max-w-xs truncate">{r.reason}</TableCell>
                    <TableCell>{r.date ? formatDateTime(r.date) : "—"}</TableCell>
                    <TableCell>
                      <div className="flex gap-1">
                        <Button
                          size="sm"
                          disabled={busyId === r.id}
                          onClick={() =>
                            void run(r.id, () => approveFinanceRefund(r.id), "Refund credited to wallet")
                          }
                        >
                          Approve
                        </Button>
                        <Button
                          size="sm"
                          variant="destructive"
                          disabled={busyId === r.id}
                          onClick={() =>
                            void run(
                              r.id,
                              () => rejectFinanceRefund(r.id, "Rejected by admin"),
                              "Refund rejected",
                            )
                          }
                        >
                          Reject
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between space-y-0">
          <div>
            <CardTitle>History — Paid & Rejected</CardTitle>
            <p className="text-sm text-muted-foreground mt-1">
              Click a row to view full withdrawal details
            </p>
          </div>
          <div className="flex gap-1">
            {(
              [
                ["all", "All"],
                ["paid", "Paid"],
                ["rejected", "Rejected"],
              ] as const
            ).map(([key, label]) => (
              <Button
                key={key}
                size="sm"
                variant={historyFilter === key ? "default" : "outline"}
                onClick={() => setHistoryFilter(key)}
              >
                {label}
              </Button>
            ))}
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Party</TableHead>
                <TableHead>Name</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Method</TableHead>
                <TableHead>Processed</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredHistory.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center text-muted-foreground py-8">
                    {loading ? "Loading…" : "No history yet"}
                  </TableCell>
                </TableRow>
              ) : (
                filteredHistory.map((h) => (
                  <TableRow
                    key={h.id}
                    className="cursor-pointer hover:bg-muted/50"
                    onClick={() => setSelected(h)}
                  >
                    <TableCell>
                      <span className="rounded-md bg-muted px-2 py-0.5 text-xs font-medium capitalize">
                        {h.party ?? "driver"}
                      </span>
                    </TableCell>
                    <TableCell>{h.partyName ?? h.driverName ?? h.userName ?? "—"}</TableCell>
                    <TableCell className="font-medium">{formatCurrency(h.amount)}</TableCell>
                    <TableCell>{h.method}</TableCell>
                    <TableCell>
                      {h.processedAt
                        ? formatDateTime(h.processedAt)
                        : h.date
                          ? formatDateTime(h.date)
                          : "—"}
                    </TableCell>
                    <TableCell>
                      <StatusBadge status={h.status} />
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Dialog open={!!selected} onOpenChange={(open) => !open && setSelected(null)}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>
              {isRejected ? "Rejected withdrawal" : selected?.status === "paid" ? "Paid withdrawal" : "Withdrawal details"}
            </DialogTitle>
            <DialogDescription>
              {isRejected
                ? "This withdrawal request was rejected by admin."
                : selected?.status === "paid"
                  ? "This withdrawal was paid to the linked account."
                  : "Pending withdrawal request details."}
            </DialogDescription>
          </DialogHeader>

          {selected && (
            <div className="grid gap-3 sm:grid-cols-2">
              <Detail label="Status">
                <StatusBadge status={selected.status} />
              </Detail>
              <Detail label="Amount">{formatCurrency(selected.amount)}</Detail>
              <Detail label="Party">
                <span className="capitalize">{selected.party ?? "driver"}</span>
              </Detail>
              <Detail label="Name">
                {selected.partyName ?? selected.driverName ?? selected.userName ?? "—"}
              </Detail>
              {(selected.partyPublicId ||
                selected.driverPublicId ||
                selected.userPublicId) && (
                <Detail label="ID">
                  {selected.partyPublicId ||
                    selected.driverPublicId ||
                    selected.userPublicId}
                </Detail>
              )}
              <Detail label="Method">{selected.method}</Detail>
              <Detail label="Requested">
                {selected.createdAt
                  ? formatDateTime(selected.createdAt)
                  : selected.date
                    ? formatDateTime(selected.date)
                    : "—"}
              </Detail>
              <Detail label="Processed">
                {selected.processedAt ? formatDateTime(selected.processedAt) : "—"}
              </Detail>

              {isRejected && (
                <div className="sm:col-span-2 rounded-lg border border-destructive/30 bg-destructive/5 p-3">
                  <p className="text-xs text-muted-foreground">Rejection reason</p>
                  <p className="mt-1 text-sm font-medium">
                    {selected.rejectionReason || "Rejected by admin"}
                  </p>
                </div>
              )}

              {selected.bankDetails && (
                <div className="sm:col-span-2 rounded-lg border p-3 space-y-2">
                  <p className="text-xs font-medium text-muted-foreground uppercase tracking-wide">
                    Bank details
                  </p>
                  <div className="grid gap-2 sm:grid-cols-2 text-sm">
                    <div>
                      <p className="text-xs text-muted-foreground">Account holder</p>
                      <p className="font-medium">
                        {selected.bankDetails.accountHolder || "—"}
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Bank</p>
                      <p className="font-medium">{selected.bankDetails.bankName || "—"}</p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Account number</p>
                      <p className="font-medium font-mono">
                        {selected.bankDetails.accountNumber || "—"}
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">IFSC</p>
                      <p className="font-medium font-mono">
                        {selected.bankDetails.ifsc || "—"}
                      </p>
                    </div>
                    {selected.bankDetails.upiId ? (
                      <div className="sm:col-span-2">
                        <p className="text-xs text-muted-foreground">UPI</p>
                        <p className="font-medium">{selected.bankDetails.upiId}</p>
                      </div>
                    ) : null}
                  </div>
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}

function Detail({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="rounded-lg border p-3">
      <p className="text-xs text-muted-foreground">{label}</p>
      <div className="mt-1 text-sm font-medium">{children}</div>
    </div>
  );
}
