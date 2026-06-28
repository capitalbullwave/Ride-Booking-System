"use client";

import { useCallback, useEffect, useState, use } from "react";
import { notFound } from "next/navigation";
import {
  ArrowLeft,
  Pencil,
  CheckCircle,
  XCircle,
  Ban,
  RotateCcw,
  Star,
  FileText,
  ChevronDown,
} from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Driver, DriverStatus } from "@/types";
import { formatCurrency, formatDate, formatDateTime, capitalize } from "@/lib/format";
import {
  approveDriver,
  DriverDocument,
  DriverRide,
  fetchDriver,
  fetchDriverDocuments,
  fetchDriverRides,
  reactivateDriver,
  rejectDriver,
  setDriverStatus,
  suspendDriver,
  updateDriver,
} from "@/lib/drivers-api";
import { toast } from "sonner";
import { useAutoRefresh } from "@/hooks/use-auto-refresh";
import {
  createDriverFormData,
  DriverEditFormFields,
  DriverFormData,
} from "@/components/drivers/driver-edit-form-fields";

type ConfirmAction =
  | "approve"
  | "reject"
  | "suspend"
  | "reactivate"
  | "setOnline"
  | "setOffline"
  | "setBusy"
  | "setRejected"
  | "setSuspended";

const statusActions: {
  action: ConfirmAction;
  status: DriverStatus;
  label: string;
  destructive?: boolean;
}[] = [
  { action: "setOnline", status: "online", label: "Mark as Online" },
  { action: "setOffline", status: "offline", label: "Mark as Offline" },
  { action: "setBusy", status: "busy", label: "Mark as Busy" },
  { action: "setRejected", status: "rejected", label: "Mark as Rejected", destructive: true },
  { action: "setSuspended", status: "suspended", label: "Mark as Suspended", destructive: true },
];

const confirmConfig: Record<
  ConfirmAction,
  { title: string; description: (name: string) => string; button: string; destructive?: boolean }
> = {
  approve: {
    title: "Approve Driver",
    description: (name) =>
      `Approve ${name}? The driver will be marked as online and can start accepting rides.`,
    button: "Approve Driver",
  },
  reject: {
    title: "Reject Driver",
    description: (name) =>
      `Reject ${name}'s application? They will not be able to operate on the platform.`,
    button: "Reject Driver",
    destructive: true,
  },
  suspend: {
    title: "Suspend Driver",
    description: (name) =>
      `Suspend ${name}? The driver will temporarily lose access until reactivated.`,
    button: "Suspend Driver",
  },
  reactivate: {
    title: "Reactivate Driver",
    description: (name) =>
      `Reactivate ${name}? The driver will be set to offline and can go online again.`,
    button: "Reactivate Driver",
  },
  setOnline: {
    title: "Set Online",
    description: (name) => `Set ${name}'s status to online?`,
    button: "Set Online",
  },
  setOffline: {
    title: "Set Offline",
    description: (name) => `Set ${name}'s status to offline?`,
    button: "Set Offline",
  },
  setBusy: {
    title: "Set Busy",
    description: (name) => `Set ${name}'s status to busy?`,
    button: "Set Busy",
  },
  setRejected: {
    title: "Set Rejected",
    description: (name) => `Set ${name}'s status to rejected?`,
    button: "Set Rejected",
    destructive: true,
  },
  setSuspended: {
    title: "Set Suspended",
    description: (name) => `Set ${name}'s status to suspended?`,
    button: "Set Suspended",
    destructive: true,
  },
};

function buildDriverUpdatePayload(form: DriverFormData) {
  return {
    name: form.name.trim(),
    phone: form.phone.trim(),
    email: form.email.trim(),
    city: form.city.trim(),
    joinedDate: form.joinedDate,
    status: form.status,
  };
}

export default function DriverDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const [driver, setDriver] = useState<Driver | null>(null);
  const [driverRides, setDriverRides] = useState<DriverRide[]>([]);
  const [documents, setDocuments] = useState<DriverDocument[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [notFoundState, setNotFoundState] = useState(false);
  const [editOpen, setEditOpen] = useState(false);
  const [editForm, setEditForm] = useState<DriverFormData>({
    name: "",
    phone: "",
    email: "",
    city: "",
    joinedDate: "",
    status: "pending",
  });
  const [isSaving, setIsSaving] = useState(false);
  const [isActionLoading, setIsActionLoading] = useState(false);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [confirmAction, setConfirmAction] = useState<ConfirmAction | null>(null);

  const loadDriverData = useCallback(async (options?: { silent?: boolean }) => {
    if (!options?.silent) {
      setIsLoading(true);
      setNotFoundState(false);
    }

    try {
      const [driverData, rides, docs] = await Promise.all([
        fetchDriver(id),
        fetchDriverRides(id),
        fetchDriverDocuments(id),
      ]);

      setDriver(driverData);
      setDriverRides(rides);
      setDocuments(docs);
    } catch (error) {
      if (error instanceof Error && error.message.includes("not found")) {
        setNotFoundState(true);
      } else if (!options?.silent) {
        toast.error(
          error instanceof Error ? error.message : "Failed to load driver details",
        );
      }
    } finally {
      if (!options?.silent) {
        setIsLoading(false);
      }
    }
  }, [id]);

  useEffect(() => {
    void loadDriverData();
  }, [loadDriverData]);

  useAutoRefresh(() => loadDriverData({ silent: true }));

  if (notFoundState) notFound();

  const openEdit = () => {
    if (!driver) return;
    setEditForm(createDriverFormData(driver));
    setEditOpen(true);
  };

  const handleEdit = async () => {
    if (!driver) return;

    if (!editForm.name.trim() || !editForm.email.trim()) {
      toast.error("Name and email are required");
      return;
    }

    setIsSaving(true);
    try {
      await updateDriver(driver.id, buildDriverUpdatePayload(editForm));
      await loadDriverData({ silent: true });
      setEditOpen(false);
      toast.success("Driver updated successfully");
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to update driver",
      );
    } finally {
      setIsSaving(false);
    }
  };

  const openConfirm = (action: ConfirmAction) => {
    setConfirmAction(action);
    setConfirmOpen(true);
  };

  const closeConfirm = () => {
    setConfirmOpen(false);
    setConfirmAction(null);
  };

  const handleConfirmAction = async () => {
    if (!driver || !confirmAction) return;

    closeConfirm();
    setIsActionLoading(true);

    try {
      if (confirmAction === "approve") {
        await approveDriver(driver.id);
        toast.success(`${driver.name} has been approved`);
      } else if (confirmAction === "reject") {
        await rejectDriver(driver.id);
        toast.success(`${driver.name} has been rejected`);
      } else if (confirmAction === "suspend") {
        await suspendDriver(driver.id);
        toast.success(`${driver.name} has been suspended`);
      } else if (confirmAction === "reactivate") {
        await reactivateDriver(driver.id);
        toast.success(`${driver.name} has been reactivated`);
      } else {
        const statusMap: Partial<Record<ConfirmAction, DriverStatus>> = {
          setOnline: "online",
          setOffline: "offline",
          setBusy: "busy",
          setRejected: "rejected",
          setSuspended: "suspended",
        };
        const newStatus = statusMap[confirmAction];
        if (newStatus) {
          await setDriverStatus(driver.id, newStatus);
          toast.success(`${driver.name} is now ${capitalize(newStatus)}`);
        }
      }

      await loadDriverData({ silent: true });
    } catch (error) {
      const fallback =
        confirmAction === "approve"
          ? "Failed to approve driver"
          : confirmAction === "reject"
            ? "Failed to reject driver"
            : confirmAction === "suspend"
              ? "Failed to suspend driver"
              : confirmAction === "reactivate"
                ? "Failed to reactivate driver"
                : "Failed to update driver status";
      toast.error(error instanceof Error ? error.message : fallback);
    } finally {
      setIsActionLoading(false);
    }
  };

  if (isLoading || !driver) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <ButtonLink variant="ghost" size="icon" href="/drivers">
            <ArrowLeft className="h-4 w-4" />
          </ButtonLink>
          <PageHeader title="Loading driver..." description={`Driver ID: ${id}`} />
        </div>
        <div className="rounded-xl border bg-card p-6 text-sm text-muted-foreground">
          Fetching driver details...
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <ButtonLink variant="ghost" size="icon" href="/drivers">
          <ArrowLeft className="h-4 w-4" />
        </ButtonLink>
        <PageHeader title={driver.name} description={`Driver ID: ${driver.id}`}>
          <Button variant="outline" size="sm" onClick={openEdit} disabled={isActionLoading}>
            <Pencil className="mr-2 h-4 w-4" /> Edit
          </Button>
          <DropdownMenu>
            <DropdownMenuTrigger render={<Button variant="outline" size="sm" disabled={isActionLoading} />}>
              Actions
              <ChevronDown className="ml-2 h-4 w-4" />
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-52">
              {driver.status === "pending" && (
                <>
                  <DropdownMenuItem onClick={() => openConfirm("approve")}>
                    <CheckCircle className="mr-2 h-4 w-4" /> Approve
                  </DropdownMenuItem>
                  <DropdownMenuItem onClick={() => openConfirm("reject")}>
                    <XCircle className="mr-2 h-4 w-4" /> Reject
                  </DropdownMenuItem>
                  <DropdownMenuSeparator />
                </>
              )}
              <DropdownMenuGroup>
                <DropdownMenuLabel>Change Status</DropdownMenuLabel>
                {statusActions.map(({ action, status, label, destructive }) => (
                  <DropdownMenuItem
                    key={action}
                    variant={destructive ? "destructive" : "default"}
                    disabled={driver.status === status}
                    onClick={() => openConfirm(action)}
                  >
                    {label}
                  </DropdownMenuItem>
                ))}
              </DropdownMenuGroup>
              {driver.status === "suspended" && (
                <>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem onClick={() => openConfirm("reactivate")}>
                    <RotateCcw className="mr-2 h-4 w-4" /> Reactivate
                  </DropdownMenuItem>
                </>
              )}
              {driver.status !== "rejected" &&
                driver.status !== "pending" &&
                driver.status !== "suspended" && (
                  <>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem
                      variant="destructive"
                      onClick={() => openConfirm("suspend")}
                    >
                      <Ban className="mr-2 h-4 w-4" /> Suspend
                    </DropdownMenuItem>
                  </>
                )}
            </DropdownMenuContent>
          </DropdownMenu>
        </PageHeader>
      </div>

      <div className="flex items-center gap-4 rounded-xl border bg-card p-6">
        <Avatar className="h-16 w-16">
          <AvatarFallback className="bg-primary text-primary-foreground text-xl">
            {driver.name.split(" ").map((n) => n[0]).join("")}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1">
          <div className="flex items-center gap-3">
            <h2 className="text-xl font-semibold">{driver.name}</h2>
            <StatusBadge status={driver.status} />
          </div>
          <p className="text-sm text-muted-foreground">
            {driver.phone} · {capitalize(driver.vehicleType)} · {driver.vehicleNumber}
          </p>
        </div>
        <div className="grid grid-cols-4 gap-6 text-center">
          <div>
            <p className="text-2xl font-bold flex items-center justify-center gap-1">
              <Star className="h-5 w-5 text-amber-500" /> {driver.rating}
            </p>
            <p className="text-xs text-muted-foreground">Rating</p>
          </div>
          <div>
            <p className="text-2xl font-bold">{driver.totalTrips.toLocaleString()}</p>
            <p className="text-xs text-muted-foreground">Total Trips</p>
          </div>
          <div>
            <p className="text-2xl font-bold">{formatCurrency(driver.earnings)}</p>
            <p className="text-xs text-muted-foreground">Earnings</p>
          </div>
          <div>
            <p className="text-2xl font-bold">{formatCurrency(driver.walletBalance)}</p>
            <p className="text-xs text-muted-foreground">Wallet</p>
          </div>
        </div>
      </div>

      <Tabs defaultValue="personal">
        <TabsList className="flex-wrap">
          <TabsTrigger value="personal">Personal Info</TabsTrigger>
          <TabsTrigger value="documents">Documents</TabsTrigger>
          <TabsTrigger value="vehicle">Vehicle</TabsTrigger>
          <TabsTrigger value="rides">Ride History</TabsTrigger>
        </TabsList>

        <TabsContent value="personal" className="mt-6">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle>Personal Information</CardTitle>
              <Button variant="outline" size="sm" onClick={openEdit}>
                <Pencil className="mr-2 h-4 w-4" /> Edit Profile
              </Button>
            </CardHeader>
            <CardContent className="grid gap-4 sm:grid-cols-2">
              {[
                ["Full Name", driver.name],
                ["Email", driver.email],
                ["Phone", driver.phone],
                ["City", driver.city],
                ["Joined Date", formatDate(driver.joinedDate)],
                ["Status", capitalize(driver.status)],
              ].map(([label, value]) => (
                <div key={label} className="rounded-lg border p-4">
                  <p className="text-xs text-muted-foreground">{label}</p>
                  <p className="mt-1 font-medium">{value}</p>
                </div>
              ))}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="documents" className="mt-6">
          <Card>
            <CardHeader><CardTitle>Document Verification</CardTitle></CardHeader>
            <CardContent>
              {documents.length === 0 ? (
                <p className="text-sm text-muted-foreground">No documents found.</p>
              ) : (
                <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                  {documents.map((doc) => (
                    <div key={doc.id} className="rounded-lg border p-4">
                      <div className="flex items-start justify-between">
                        <div className="flex items-center gap-3">
                          <div className="rounded-lg bg-muted p-2">
                            <FileText className="h-5 w-5" />
                          </div>
                          <div>
                            <p className="font-medium">{doc.name}</p>
                            <p className="text-xs text-muted-foreground">
                              Uploaded {formatDate(doc.uploadedAt)}
                            </p>
                          </div>
                        </div>
                        <StatusBadge status={doc.status} />
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="vehicle" className="mt-6">
          <Card>
            <CardHeader><CardTitle>Vehicle Information</CardTitle></CardHeader>
            <CardContent className="grid gap-4 sm:grid-cols-2">
              {[
                ["Vehicle Type", capitalize(driver.vehicleType)],
                ["Vehicle Number", driver.vehicleNumber],
                ["City", driver.city],
                ["Status", capitalize(driver.status)],
              ].map(([label, value]) => (
                <div key={label} className="rounded-lg border p-4">
                  <p className="text-xs text-muted-foreground">{label}</p>
                  <p className="mt-1 font-medium">{value}</p>
                </div>
              ))}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="rides" className="mt-6">
          <Card>
            <CardHeader><CardTitle>Ride History</CardTitle></CardHeader>
            <CardContent>
              {driverRides.length === 0 ? (
                <p className="text-sm text-muted-foreground">No rides found for this driver.</p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Ride ID</TableHead>
                      <TableHead>User</TableHead>
                      <TableHead>Route</TableHead>
                      <TableHead>Fare</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Date</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {driverRides.map((ride) => (
                      <TableRow key={ride.id}>
                        <TableCell className="font-mono text-xs">{ride.id}</TableCell>
                        <TableCell>{ride.userName}</TableCell>
                        <TableCell className="max-w-[200px] truncate">
                          {ride.pickupLocation} → {ride.dropLocation}
                        </TableCell>
                        <TableCell>{formatCurrency(ride.fare)}</TableCell>
                        <TableCell><StatusBadge status={ride.status} /></TableCell>
                        <TableCell>{formatDateTime(ride.date)}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>Edit Driver</DialogTitle>
            <DialogDescription>
              Update profile details for {driver.name}
            </DialogDescription>
          </DialogHeader>
          <DriverEditFormFields
            form={editForm}
            onChange={(updates) => setEditForm((form) => ({ ...form, ...updates }))}
            idPrefix="detail-edit"
          />
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditOpen(false)}>
              Cancel
            </Button>
            <Button onClick={() => void handleEdit()} disabled={isSaving}>
              {isSaving ? "Saving..." : "Save Changes"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={confirmOpen} onOpenChange={(open) => !open && closeConfirm()}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>
              {confirmAction ? confirmConfig[confirmAction].title : "Confirm Action"}
            </DialogTitle>
            <DialogDescription>
              {confirmAction ? confirmConfig[confirmAction].description(driver.name) : null}
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={closeConfirm}>
              Cancel
            </Button>
            <Button
              variant={
                confirmAction && confirmConfig[confirmAction].destructive
                  ? "destructive"
                  : "default"
              }
              onClick={() => void handleConfirmAction()}
              disabled={isActionLoading}
            >
              {confirmAction ? confirmConfig[confirmAction].button : "Confirm"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
