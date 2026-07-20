"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { ScanFace, RefreshCw, Trash2 } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { StatusBadge } from "@/components/shared/status-badge";
import { formatDateTime } from "@/lib/format";
import {
  deleteSelfieVerification,
  fetchOnlineVerifiedDrivers,
  fetchSelfieVerification,
  fetchSelfieVerifications,
  forceOfflineDriver,
  OnlineVerifiedDriver,
  SelfieVerificationLog,
} from "@/lib/selfie-api";
import { toast } from "sonner";

export default function SelfieVerificationsPage() {
  const [logs, setLogs] = useState<SelfieVerificationLog[]>([]);
  const [online, setOnline] = useState<OnlineVerifiedDriver[]>([]);
  const [statusFilter, setStatusFilter] = useState("all");
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState<SelfieVerificationLog | null>(null);
  const [detailOpen, setDetailOpen] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<SelfieVerificationLog | null>(
    null,
  );
  const [deleting, setDeleting] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [verifications, onlineDrivers] = await Promise.all([
        fetchSelfieVerifications({
          status: statusFilter === "all" ? undefined : statusFilter,
          limit: 50,
        }),
        fetchOnlineVerifiedDrivers(),
      ]);
      setLogs(verifications.items);
      setOnline(onlineDrivers);
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to load verifications",
      );
    } finally {
      setLoading(false);
    }
  }, [statusFilter]);

  useEffect(() => {
    void load();
  }, [load]);

  async function openDetail(id: string) {
    try {
      const detail = await fetchSelfieVerification(id);
      setSelected(detail);
      setDetailOpen(true);
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to load detail",
      );
    }
  }

  async function handleForceOffline(driverId: string) {
    try {
      await forceOfflineDriver(driverId);
      toast.success("Driver forced offline");
      await load();
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to force offline",
      );
    }
  }

  async function handleDeleteLog() {
    if (!deleteTarget) return;
    setDeleting(true);
    try {
      await deleteSelfieVerification(deleteTarget.id);
      toast.success("Verification record deleted");
      if (selected?.id === deleteTarget.id) {
        setDetailOpen(false);
        setSelected(null);
      }
      setDeleteTarget(null);
      await load();
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to delete record",
      );
    } finally {
      setDeleting(false);
    }
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title="Selfie Verification"
        description="Shift selfie history, failed attempts, and currently online verified drivers."
        actions={
          <Button variant="outline" onClick={() => void load()} disabled={loading}>
            <RefreshCw className="mr-2 h-4 w-4" />
            Refresh
          </Button>
        }
      />

      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Attempts loaded</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-semibold">{logs.length}</CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Failed</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-semibold">
            {logs.filter((l) => l.status === "failed").length}
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Online verified</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-semibold">{online.length}</CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <ScanFace className="h-5 w-5" />
            Online verified drivers
          </CardTitle>
        </CardHeader>
        <CardContent>
          {online.length === 0 ? (
            <p className="text-sm text-muted-foreground">No verified online drivers.</p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Driver</TableHead>
                  <TableHead>Phone</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Shift started</TableHead>
                  <TableHead />
                </TableRow>
              </TableHeader>
              <TableBody>
                {online.map((d) => (
                  <TableRow key={d.id}>
                    <TableCell>
                      <Link className="underline" href={`/drivers/${d.id}`}>
                        {d.name}
                      </Link>
                    </TableCell>
                    <TableCell>{d.phone}</TableCell>
                    <TableCell>
                      <StatusBadge status={d.status.toLowerCase()} />
                    </TableCell>
                    <TableCell>
                      {d.shift.startedAt ? formatDateTime(d.shift.startedAt) : "—"}
                    </TableCell>
                    <TableCell className="text-right">
                      <Button
                        size="sm"
                        variant="destructive"
                        onClick={() => void handleForceOffline(d.id)}
                      >
                        Force offline
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between gap-4">
          <CardTitle>Verification history</CardTitle>
          <select
            className="rounded-md border px-3 py-2 text-sm"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="all">All</option>
            <option value="success">Success</option>
            <option value="failed">Failed</option>
            <option value="rate_limited">Rate limited</option>
          </select>
        </CardHeader>
        <CardContent>
          {loading ? (
            <p className="text-sm text-muted-foreground">Loading…</p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Driver</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Score</TableHead>
                  <TableHead>Liveness</TableHead>
                  <TableHead>Attempt</TableHead>
                  <TableHead>When</TableHead>
                  <TableHead />
                </TableRow>
              </TableHeader>
              <TableBody>
                {logs.map((log) => (
                  <TableRow key={log.id}>
                    <TableCell>
                      <div className="font-medium">{log.driverName ?? log.driverId}</div>
                      <div className="text-xs text-muted-foreground">
                        {log.driverPhone}
                      </div>
                    </TableCell>
                    <TableCell>
                      <StatusBadge status={log.status} />
                    </TableCell>
                    <TableCell>
                      {log.confidenceScore != null
                        ? `${log.confidenceScore.toFixed(1)}%`
                        : "—"}
                    </TableCell>
                    <TableCell>{log.livenessPassed ? "Passed" : "Failed"}</TableCell>
                    <TableCell>{log.attemptNumber}</TableCell>
                    <TableCell>
                      {log.createdAt ? formatDateTime(log.createdAt) : "—"}
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-2">
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => void openDetail(log.id)}
                        >
                          View
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          className="text-destructive hover:bg-destructive/10 hover:text-destructive"
                          disabled={deleting}
                          onClick={() => setDeleteTarget(log)}
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      <Dialog open={detailOpen} onOpenChange={setDetailOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Verification detail</DialogTitle>
          </DialogHeader>
          {selected && (
            <div className="space-y-4">
              {selected.selfieImageDataUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={selected.selfieImageDataUrl}
                  alt="Driver selfie"
                  className="max-h-72 w-full rounded-md object-contain bg-muted"
                />
              ) : (
                <p className="text-sm text-muted-foreground">No selfie image available.</p>
              )}
              <dl className="grid grid-cols-2 gap-3 text-sm">
                <div>
                  <dt className="text-muted-foreground">Driver</dt>
                  <dd>{selected.driverName}</dd>
                </div>
                <div>
                  <dt className="text-muted-foreground">Score</dt>
                  <dd>
                    {selected.confidenceScore != null
                      ? `${selected.confidenceScore.toFixed(1)}%`
                      : "—"}
                  </dd>
                </div>
                <div>
                  <dt className="text-muted-foreground">Provider</dt>
                  <dd>{selected.faceProvider ?? "—"}</dd>
                </div>
                <div>
                  <dt className="text-muted-foreground">Error</dt>
                  <dd>{selected.errorCode ?? "—"}</dd>
                </div>
              </dl>
              {selected.errorMessage && (
                <p className="text-sm text-destructive">{selected.errorMessage}</p>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>

      <Dialog
        open={!!deleteTarget}
        onOpenChange={(open) => {
          if (!open) setDeleteTarget(null);
        }}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete verification record?</DialogTitle>
            <DialogDescription>
              This permanently removes the attempt
              {deleteTarget?.createdAt
                ? ` from ${formatDateTime(deleteTarget.createdAt)}`
                : ""}{" "}
              and its stored selfie. This cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setDeleteTarget(null)}
              disabled={deleting}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              disabled={deleting}
              onClick={() => void handleDeleteLog()}
            >
              {deleting ? "Deleting…" : "Delete"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
