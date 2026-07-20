"use client";

import { useMemo, useState } from "react";
import {
  Ban,
  CheckCircle2,
  Clock3,
  Eye,
  ScanFace,
  ShieldAlert,
  Trash2,
  XCircle,
} from "lucide-react";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { formatDateTime } from "@/lib/format";
import {
  DriverShiftRecord,
  deleteSelfieVerification,
  fetchSelfieVerification,
  forceOfflineDriver,
  SelfieVerificationLog,
} from "@/lib/selfie-api";
import { Driver } from "@/types";
import { toast } from "sonner";

type Props = {
  driver: Driver;
  shifts: DriverShiftRecord[];
  selfieLogs: SelfieVerificationLog[];
  onRefresh: () => Promise<void> | void;
};

function scoreLabel(score?: number | null) {
  if (score == null) return "—";
  return `${score.toFixed(1)}%`;
}

export function DriverSelfieVerification({
  driver,
  shifts,
  selfieLogs,
  onRefresh,
}: Props) {
  const [detailOpen, setDetailOpen] = useState(false);
  const [selected, setSelected] = useState<SelfieVerificationLog | null>(null);
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [forceOpen, setForceOpen] = useState(false);
  const [forcing, setForcing] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<SelfieVerificationLog | null>(
    null,
  );
  const [deleting, setDeleting] = useState(false);

  const activeShift = useMemo(
    () => shifts.find((s) => s.status === "active") ?? null,
    [shifts],
  );

  const failedCount = useMemo(
    () => selfieLogs.filter((l) => l.status === "failed" || l.status === "rate_limited").length,
    [selfieLogs],
  );

  const successCount = useMemo(
    () => selfieLogs.filter((l) => l.status === "success").length,
    [selfieLogs],
  );

  const lastAttempt = selfieLogs[0] ?? null;

  async function openDetail(logId: string) {
    setLoadingDetail(true);
    try {
      const detail = await fetchSelfieVerification(logId);
      setSelected(detail);
      setDetailOpen(true);
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to load selfie detail",
      );
    } finally {
      setLoadingDetail(false);
    }
  }

  async function handleForceOffline() {
    setForcing(true);
    try {
      await forceOfflineDriver(
        driver.id,
        "Forced offline from driver selfie panel",
      );
      toast.success(`${driver.name} forced offline`);
      setForceOpen(false);
      await onRefresh();
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to force offline",
      );
    } finally {
      setForcing(false);
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
      await onRefresh();
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
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardContent className="flex items-center gap-3 p-4">
            <div className="rounded-lg bg-primary/10 p-2">
              <Clock3 className="h-5 w-5 text-primary" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Active shift</p>
              <p className="font-semibold">
                {activeShift ? (
                  <StatusBadge status="active" />
                ) : (
                  "None"
                )}
              </p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 p-4">
            <div className="rounded-lg bg-success/15 p-2">
              <CheckCircle2 className="h-5 w-5 text-success" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Successful checks</p>
              <p className="text-xl font-semibold">{successCount}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 p-4">
            <div className="rounded-lg bg-destructive/15 p-2">
              <XCircle className="h-5 w-5 text-destructive" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Failed attempts</p>
              <p className="text-xl font-semibold">{failedCount}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 p-4">
            <div className="rounded-lg bg-secondary/30 p-2">
              <ScanFace className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Last score</p>
              <p className="text-xl font-semibold">
                {scoreLabel(lastAttempt?.confidenceScore)}
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between gap-3">
          <div>
            <CardTitle className="flex items-center gap-2">
              <ScanFace className="h-5 w-5" />
              Current shift status
            </CardTitle>
            <p className="mt-1 text-sm text-muted-foreground">
              Selfie is required once per shift before the driver can go online.
            </p>
          </div>
          <Button
            variant="destructive"
            size="sm"
            onClick={() => setForceOpen(true)}
            disabled={
              driver.status !== "online" &&
              driver.status !== "busy" &&
              !activeShift
            }
          >
            <Ban className="mr-2 h-4 w-4" />
            Force offline
          </Button>
        </CardHeader>
        <CardContent className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {[
            [
              "Driver status",
              <StatusBadge key="ds" status={driver.status} />,
            ],
            [
              "Shift status",
              activeShift ? (
                <StatusBadge key="ss" status={activeShift.status} />
              ) : (
                "No active shift"
              ),
            ],
            [
              "Selfie verified",
              activeShift?.selfieVerified ? (
                <span key="sv" className="font-medium text-success">
                  Yes
                </span>
              ) : (
                <span key="sv" className="font-medium text-muted-foreground">
                  No
                </span>
              ),
            ],
            [
              "Shift started",
              activeShift?.startedAt
                ? formatDateTime(activeShift.startedAt)
                : "—",
            ],
          ].map(([label, value]) => (
            <div key={String(label)} className="rounded-lg border p-4">
              <p className="text-xs text-muted-foreground">{label}</p>
              <div className="mt-1 font-medium">{value}</div>
            </div>
          ))}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Verification history</CardTitle>
        </CardHeader>
        <CardContent>
          {selfieLogs.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              No selfie verification attempts for this driver yet.
            </p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>When</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Score</TableHead>
                  <TableHead>Liveness</TableHead>
                  <TableHead>Match</TableHead>
                  <TableHead>Attempt</TableHead>
                  <TableHead>Error</TableHead>
                  <TableHead className="text-right">Selfie</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {selfieLogs.map((log) => (
                  <TableRow key={log.id}>
                    <TableCell className="whitespace-nowrap text-sm">
                      {log.createdAt ? formatDateTime(log.createdAt) : "—"}
                    </TableCell>
                    <TableCell>
                      <StatusBadge status={log.status} />
                    </TableCell>
                    <TableCell>{scoreLabel(log.confidenceScore)}</TableCell>
                    <TableCell>
                      {log.livenessPassed ? (
                        <span className="text-success">Passed</span>
                      ) : (
                        <span className="text-destructive">Failed</span>
                      )}
                    </TableCell>
                    <TableCell>
                      {log.matched ? (
                        <span className="text-success">Matched</span>
                      ) : (
                        <span className="text-muted-foreground">No</span>
                      )}
                    </TableCell>
                    <TableCell>{log.attemptNumber}</TableCell>
                    <TableCell className="max-w-[160px] truncate text-sm">
                      {log.errorCode || "—"}
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-2">
                        <Button
                          size="sm"
                          variant="outline"
                          disabled={loadingDetail}
                          onClick={() => void openDetail(log.id)}
                        >
                          <Eye className="mr-1 h-3.5 w-3.5" />
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

      <Card>
        <CardHeader>
          <CardTitle>Shift history</CardTitle>
        </CardHeader>
        <CardContent>
          {shifts.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              No shift records yet. A shift is created each time the driver goes
              online after selfie verification.
            </p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Started</TableHead>
                  <TableHead>Ended</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Selfie</TableHead>
                  <TableHead>Verified at</TableHead>
                  <TableHead>Close reason</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {shifts.map((shift) => (
                  <TableRow key={shift.id}>
                    <TableCell className="whitespace-nowrap text-sm">
                      {shift.startedAt ? formatDateTime(shift.startedAt) : "—"}
                    </TableCell>
                    <TableCell className="whitespace-nowrap text-sm">
                      {shift.endedAt ? formatDateTime(shift.endedAt) : "—"}
                    </TableCell>
                    <TableCell>
                      <StatusBadge status={shift.status} />
                    </TableCell>
                    <TableCell>
                      {shift.selfieVerified ? (
                        <span className="inline-flex items-center gap-1 text-success">
                          <CheckCircle2 className="h-3.5 w-3.5" />
                          Verified
                        </span>
                      ) : (
                        "No"
                      )}
                    </TableCell>
                    <TableCell className="whitespace-nowrap text-sm">
                      {shift.selfieVerifiedAt
                        ? formatDateTime(shift.selfieVerifiedAt)
                        : "—"}
                    </TableCell>
                    <TableCell className="max-w-[220px] truncate text-sm">
                      {shift.forceCloseReason || "—"}
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
            <DialogTitle>Selfie verification detail</DialogTitle>
            <DialogDescription>
              Score, liveness result, and captured live selfie for {driver.name}.
            </DialogDescription>
          </DialogHeader>
          {selected && (
            <div className="space-y-4">
              {selected.selfieImageDataUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={selected.selfieImageDataUrl}
                  alt="Driver verification selfie"
                  className="max-h-72 w-full rounded-md bg-muted object-contain"
                />
              ) : (
                <div className="flex items-center gap-2 rounded-md border border-dashed p-6 text-sm text-muted-foreground">
                  <ShieldAlert className="h-4 w-4" />
                  Selfie image not available for this attempt.
                </div>
              )}
              <dl className="grid grid-cols-2 gap-3 text-sm">
                <div>
                  <dt className="text-muted-foreground">Status</dt>
                  <dd className="mt-1">
                    <StatusBadge status={selected.status} />
                  </dd>
                </div>
                <div>
                  <dt className="text-muted-foreground">Confidence</dt>
                  <dd className="mt-1 font-medium">
                    {scoreLabel(selected.confidenceScore)}
                  </dd>
                </div>
                <div>
                  <dt className="text-muted-foreground">Face provider</dt>
                  <dd className="mt-1 font-medium">
                    {selected.faceProvider || "—"}
                  </dd>
                </div>
                <div>
                  <dt className="text-muted-foreground">Liveness</dt>
                  <dd className="mt-1 font-medium">
                    {selected.livenessPassed ? "Passed" : "Failed"}
                  </dd>
                </div>
                <div>
                  <dt className="text-muted-foreground">Attempt</dt>
                  <dd className="mt-1 font-medium">{selected.attemptNumber}</dd>
                </div>
                <div>
                  <dt className="text-muted-foreground">When</dt>
                  <dd className="mt-1 font-medium">
                    {selected.createdAt
                      ? formatDateTime(selected.createdAt)
                      : "—"}
                  </dd>
                </div>
              </dl>
              {selected.errorMessage && (
                <p className="rounded-md bg-destructive/10 px-3 py-2 text-sm text-destructive">
                  {selected.errorCode ? `${selected.errorCode}: ` : ""}
                  {selected.errorMessage}
                </p>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>

      <Dialog open={forceOpen} onOpenChange={setForceOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Force offline driver?</DialogTitle>
            <DialogDescription>
              This will force-close {driver.name}&apos;s active shift and set
              them offline immediately.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setForceOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              disabled={forcing}
              onClick={() => void handleForceOffline()}
            >
              {forcing ? "Forcing…" : "Force offline"}
            </Button>
          </DialogFooter>
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
