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
import { formatCurrency, formatDate, formatDateTime, capitalize, formatPublicId } from "@/lib/format";
import {
  approveDriver,
  creditDriverWallet,
  DriverDocument,
  DriverRide,
  DriverWalletSummary,
  fetchDriver,
  fetchDriverDocuments,
  fetchDriverRides,
  fetchDriverWallet,
  reactivateDriver,
  rejectDriver,
  setDriverStatus,
  suspendDriver,
  updateDriver,
  updateDriverBank,
} from "@/lib/drivers-api";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
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
  const [wallet, setWallet] = useState<DriverWalletSummary | null>(null);
  const [creditAmount, setCreditAmount] = useState("");
  const [creditNote, setCreditNote] = useState("");
  const [isCrediting, setIsCrediting] = useState(false);
  const [bankEditOpen, setBankEditOpen] = useState(false);
  const [bankForm, setBankForm] = useState({
    accountHolder: "",
    accountNumber: "",
    ifsc: "",
    bankName: "",
    upiId: "",
  });
  const [isSavingBank, setIsSavingBank] = useState(false);
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
      const [driverData, rides, docs, walletData] = await Promise.all([
        fetchDriver(id),
        fetchDriverRides(id),
        fetchDriverDocuments(id),
        fetchDriverWallet(id),
      ]);

      setDriver(driverData);
      setDriverRides(rides);
      setDocuments(docs);
      setWallet(walletData);
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
        <PageHeader title={driver.name} description={`Driver ID: ${formatPublicId(driver.publicId, driver.id)}`}>
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
            <p className="text-xs text-muted-foreground">Commission Earned</p>
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
          <TabsTrigger value="bank">Bank Details</TabsTrigger>
          <TabsTrigger value="wallet">Wallet</TabsTrigger>
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
                ["Date of Birth", driver.dateOfBirth ? formatDate(driver.dateOfBirth) : "—"],
                ["Gender", driver.gender ? capitalize(driver.gender) : "—"],
                ["License Number", driver.licenseNumber || "—"],
                ["Address", driver.address || "—"],
                ["City", driver.city || "—"],
                ["State", driver.state || "—"],
                ["PIN Code", driver.pinCode || "—"],
                ["Country", driver.country || "—"],
                ["KYC Status", driver.kycStatus ? capitalize(driver.kycStatus) : "—"],
                ["Referral Code", driver.referralCode || "—"],
                ["Joined Date", formatDate(driver.joinedDate)],
                ["Account Status", capitalize(driver.status)],
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
                      {doc.url ? (
                        <a
                          href={doc.url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="mt-3 inline-block text-xs font-medium text-primary hover:underline"
                          onClick={(event) => {
                            event.preventDefault();
                            window.open(doc.url, "_blank", "noopener,noreferrer");
                          }}
                        >
                          View document
                        </a>
                      ) : (
                        <p className="mt-3 text-xs text-muted-foreground">
                          Document file unavailable
                        </p>
                      )}
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
                ["Registration Number", driver.vehicleNumber || "—"],
                ["Brand", driver.vehicleBrand || "—"],
                ["Model", driver.vehicleModel || "—"],
                ["Color", driver.vehicleColor || "—"],
                ["Year", driver.vehicleYear ? String(driver.vehicleYear) : "—"],
                ["Vehicle Status", driver.vehicleStatus ? capitalize(driver.vehicleStatus) : "—"],
                ["City", driver.city || "—"],
              ].map(([label, value]) => (
                <div key={label} className="rounded-lg border p-4">
                  <p className="text-xs text-muted-foreground">{label}</p>
                  <p className="mt-1 font-medium">{value}</p>
                </div>
              ))}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="bank" className="mt-6">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between gap-3 space-y-0">
              <CardTitle>Bank Details</CardTitle>
              {driver.bankDetails && (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    setBankForm({
                      accountHolder: driver.bankDetails?.accountHolder || "",
                      accountNumber: driver.bankDetails?.isMasked
                        ? ""
                        : driver.bankDetails?.accountNumber || "",
                      ifsc: driver.bankDetails?.ifsc || "",
                      bankName: driver.bankDetails?.bankName || "",
                      upiId: driver.bankDetails?.upiId || "",
                    });
                    setBankEditOpen(true);
                  }}
                >
                  Edit
                </Button>
              )}
            </CardHeader>
            <CardContent className="grid gap-4 sm:grid-cols-2">
              {driver.bankDetails ? (
                <>
                  {[
                    ["Account Holder", driver.bankDetails.accountHolder],
                    ["Bank Name", driver.bankDetails.bankName],
                    ["Account Number", driver.bankDetails.accountNumber],
                    ["IFSC Code", driver.bankDetails.ifsc],
                    ["UPI ID", driver.bankDetails.upiId || "—"],
                    ["Verified", driver.bankDetails.isVerified ? "Yes" : "No"],
                  ].map(([label, value]) => (
                    <div key={label} className="rounded-lg border p-4">
                      <p className="text-xs text-muted-foreground">{label}</p>
                      <p className="mt-1 font-medium font-mono tracking-wide">{value}</p>
                    </div>
                  ))}
                  {driver.bankDetails.isMasked && (
                    <p className="text-sm text-amber-700 sm:col-span-2">
                      Full account number was not stored earlier. Use Edit to enter the complete account number.
                    </p>
                  )}
                </>
              ) : (
                <p className="text-sm text-muted-foreground sm:col-span-2">
                  No bank details submitted yet.
                </p>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="wallet" className="mt-6">
          <Card>
            <CardHeader>
              <CardTitle>Driver Wallet</CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid gap-4 sm:grid-cols-3">
                <div className="rounded-lg border p-4">
                  <p className="text-xs text-muted-foreground">Available</p>
                  <p className="mt-1 text-2xl font-bold text-primary">
                    {formatCurrency(wallet?.availableBalance ?? driver.walletBalance)}
                  </p>
                </div>
                <div className="rounded-lg border p-4">
                  <p className="text-xs text-muted-foreground">Pending</p>
                  <p className="mt-1 text-2xl font-bold">
                    {formatCurrency(wallet?.pendingBalance ?? 0)}
                  </p>
                </div>
                <div className="rounded-lg border p-4">
                  <p className="text-xs text-muted-foreground">Lifetime earnings</p>
                  <p className="mt-1 text-2xl font-bold">
                    {formatCurrency(wallet?.lifetimeEarnings ?? 0)}
                  </p>
                </div>
              </div>

              <div className="rounded-lg border p-4 space-y-3">
                <p className="text-sm font-medium">Add funds</p>
                <div className="grid gap-3 sm:grid-cols-[1fr_1fr_auto]">
                  <div className="space-y-1.5">
                    <Label htmlFor="credit-amount">Amount (₹)</Label>
                    <Input
                      id="credit-amount"
                      type="number"
                      min="1"
                      step="0.01"
                      placeholder="e.g. 500"
                      value={creditAmount}
                      onChange={(e) => setCreditAmount(e.target.value)}
                    />
                  </div>
                  <div className="space-y-1.5">
                    <Label htmlFor="credit-note">Note (optional)</Label>
                    <Input
                      id="credit-note"
                      placeholder="Reason for credit"
                      value={creditNote}
                      onChange={(e) => setCreditNote(e.target.value)}
                    />
                  </div>
                  <div className="flex items-end">
                    <Button
                      disabled={isCrediting || !creditAmount}
                      onClick={async () => {
                        const amount = Number(creditAmount);
                        if (!Number.isFinite(amount) || amount <= 0) {
                          toast.error("Enter a valid amount");
                          return;
                        }
                        setIsCrediting(true);
                        try {
                          const updated = await creditDriverWallet(
                            id,
                            amount,
                            creditNote.trim() || undefined,
                          );
                          setWallet(updated);
                          setDriver((prev) =>
                            prev
                              ? { ...prev, walletBalance: updated.availableBalance }
                              : prev,
                          );
                          setCreditAmount("");
                          setCreditNote("");
                          toast.success(`Added ${formatCurrency(amount)} to wallet`);
                        } catch (error) {
                          toast.error(
                            error instanceof Error
                              ? error.message
                              : "Failed to add funds",
                          );
                        } finally {
                          setIsCrediting(false);
                        }
                      }}
                    >
                      {isCrediting ? "Adding…" : "Add"}
                    </Button>
                  </div>
                </div>
              </div>

              {(wallet?.transactions.length ?? 0) === 0 ? (
                <p className="text-sm text-muted-foreground">No wallet transactions yet.</p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Date</TableHead>
                      <TableHead>Type</TableHead>
                      <TableHead>Description</TableHead>
                      <TableHead>Amount</TableHead>
                      <TableHead>Balance after</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {wallet?.transactions.map((tx) => (
                      <TableRow key={tx.id}>
                        <TableCell className="whitespace-nowrap text-sm">
                          {tx.date ? formatDateTime(tx.date) : "—"}
                        </TableCell>
                        <TableCell className="capitalize">{tx.type}</TableCell>
                        <TableCell>{tx.description}</TableCell>
                        <TableCell className="font-medium">
                          {formatCurrency(tx.amount)}
                        </TableCell>
                        <TableCell>{formatCurrency(tx.balanceAfter)}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
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
                      <TableHead>Driver Commission</TableHead>
                      <TableHead>Company Share</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Date</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {driverRides.map((ride) => (
                      <TableRow key={ride.id}>
                        <TableCell className="font-mono text-xs">
                          {formatPublicId(ride.publicId, ride.id)}
                        </TableCell>
                        <TableCell>{ride.userName}</TableCell>
                        <TableCell className="max-w-[200px] truncate">
                          {ride.pickupLocation} → {ride.dropLocation}
                        </TableCell>
                        <TableCell>{formatCurrency(ride.fare)}</TableCell>
                        <TableCell>
                          {ride.driverEarning != null ? (
                            <span>
                              {formatCurrency(ride.driverEarning)}
                              {ride.driverCommissionPercentage != null && (
                                <span className="ml-1 text-xs text-muted-foreground">
                                  ({ride.driverCommissionPercentage}%)
                                </span>
                              )}
                            </span>
                          ) : (
                            "—"
                          )}
                        </TableCell>
                        <TableCell>
                          {ride.companyEarning != null
                            ? formatCurrency(ride.companyEarning)
                            : "—"}
                        </TableCell>
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

      <Dialog open={bankEditOpen} onOpenChange={setBankEditOpen}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>Edit Bank Details</DialogTitle>
            <DialogDescription>
              Enter the full account number — it will be visible to admins only.
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <div className="space-y-1.5 sm:col-span-2">
              <Label htmlFor="bank-holder">Account Holder</Label>
              <Input
                id="bank-holder"
                value={bankForm.accountHolder}
                onChange={(e) =>
                  setBankForm((f) => ({ ...f, accountHolder: e.target.value }))
                }
              />
            </div>
            <div className="space-y-1.5 sm:col-span-2">
              <Label htmlFor="bank-number">Account Number</Label>
              <Input
                id="bank-number"
                inputMode="numeric"
                placeholder="Full account number"
                value={bankForm.accountNumber}
                onChange={(e) =>
                  setBankForm((f) => ({ ...f, accountNumber: e.target.value }))
                }
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="bank-ifsc">IFSC</Label>
              <Input
                id="bank-ifsc"
                value={bankForm.ifsc}
                onChange={(e) =>
                  setBankForm((f) => ({ ...f, ifsc: e.target.value.toUpperCase() }))
                }
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="bank-name">Bank Name</Label>
              <Input
                id="bank-name"
                value={bankForm.bankName}
                onChange={(e) =>
                  setBankForm((f) => ({ ...f, bankName: e.target.value }))
                }
              />
            </div>
            <div className="space-y-1.5 sm:col-span-2">
              <Label htmlFor="bank-upi">UPI ID (optional)</Label>
              <Input
                id="bank-upi"
                value={bankForm.upiId}
                onChange={(e) =>
                  setBankForm((f) => ({ ...f, upiId: e.target.value }))
                }
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setBankEditOpen(false)}>
              Cancel
            </Button>
            <Button
              disabled={isSavingBank}
              onClick={async () => {
                if (
                  !bankForm.accountHolder.trim() ||
                  !bankForm.accountNumber.trim() ||
                  !bankForm.ifsc.trim() ||
                  !bankForm.bankName.trim()
                ) {
                  toast.error("Fill all required bank fields");
                  return;
                }
                setIsSavingBank(true);
                try {
                  const details = await updateDriverBank(id, {
                    accountHolder: bankForm.accountHolder.trim(),
                    accountNumber: bankForm.accountNumber.trim(),
                    ifsc: bankForm.ifsc.trim(),
                    bankName: bankForm.bankName.trim(),
                    upiId: bankForm.upiId.trim() || undefined,
                  });
                  setDriver((prev) =>
                    prev ? { ...prev, bankDetails: details ?? prev.bankDetails } : prev,
                  );
                  setBankEditOpen(false);
                  toast.success("Bank details updated");
                } catch (error) {
                  toast.error(
                    error instanceof Error
                      ? error.message
                      : "Failed to update bank details",
                  );
                } finally {
                  setIsSavingBank(false);
                }
              }}
            >
              {isSavingBank ? "Saving…" : "Save"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
