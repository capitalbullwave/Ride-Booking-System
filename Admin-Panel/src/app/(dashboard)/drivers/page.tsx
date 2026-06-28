"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import {
  MoreHorizontal,
  Eye,
  Pencil,
  CheckCircle,
  XCircle,
  RotateCcw,
} from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { SearchBar } from "@/components/shared/search-bar";
import { ExportButton } from "@/components/shared/export-button";
import { DataTable, Column } from "@/components/shared/data-table";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
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
import { formatCurrency, capitalize } from "@/lib/format";
import {
  approveDriver,
  fetchDrivers,
  reactivateDriver,
  rejectDriver,
  setDriverStatus,
  suspendDriver,
  updateDriver,
} from "@/lib/drivers-api";
import { toast } from "sonner";
import { useAutoRefresh } from "@/hooks/use-auto-refresh";

type DriverFormData = {
  name: string;
  phone: string;
  email: string;
  city: string;
};

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

function driverToForm(driver: Driver): DriverFormData {
  return {
    name: driver.name,
    phone: driver.phone,
    email: driver.email,
    city: driver.city,
  };
}

function buildDriverUpdatePayload(form: DriverFormData) {
  return {
    name: form.name.trim(),
    phone: form.phone.trim(),
    email: form.email.trim(),
    city: form.city.trim(),
  };
}

export default function DriversPage() {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [driverList, setDriverList] = useState<Driver[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [editOpen, setEditOpen] = useState(false);
  const [selectedDriver, setSelectedDriver] = useState<Driver | null>(null);
  const [editForm, setEditForm] = useState<DriverFormData>({
    name: "",
    phone: "",
    email: "",
    city: "",
  });
  const [isSaving, setIsSaving] = useState(false);
  const [actionDriverId, setActionDriverId] = useState<string | null>(null);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [confirmAction, setConfirmAction] = useState<ConfirmAction | null>(null);
  const [confirmDriver, setConfirmDriver] = useState<Driver | null>(null);

  const loadDrivers = useCallback(async (options?: { silent?: boolean }) => {
    if (!options?.silent) {
      setIsLoading(true);
    }

    try {
      const response = await fetchDrivers({
        search: search || undefined,
        status: statusFilter,
        limit: 100,
      });
      setDriverList(response.items);
    } catch (error) {
      if (!options?.silent) {
        toast.error(
          error instanceof Error ? error.message : "Failed to load drivers",
        );
        setDriverList([]);
      }
    } finally {
      if (!options?.silent) {
        setIsLoading(false);
      }
    }
  }, [search, statusFilter]);

  useEffect(() => {
    const timer = setTimeout(() => {
      void loadDrivers();
    }, 300);
    return () => clearTimeout(timer);
  }, [loadDrivers]);

  useAutoRefresh(() => loadDrivers({ silent: true }));

  const filteredDrivers = useMemo(() => driverList, [driverList]);

  const driversExportPath = useMemo(() => {
    const query = new URLSearchParams();
    if (search) query.set("search", search);
    if (statusFilter !== "all") query.set("status", statusFilter);
    const qs = query.toString();
    return `/api/v1/drivers/export${qs ? `?${qs}` : ""}`;
  }, [search, statusFilter]);

  const openEdit = (driver: Driver) => {
    setSelectedDriver(driver);
    setEditForm(driverToForm(driver));
    setEditOpen(true);
  };

  const handleEdit = async () => {
    if (!selectedDriver) return;

    if (!editForm.name.trim() || !editForm.email.trim()) {
      toast.error("Name and email are required");
      return;
    }

    setIsSaving(true);
    try {
      await updateDriver(selectedDriver.id, buildDriverUpdatePayload(editForm));
      await loadDrivers({ silent: true });
      setEditOpen(false);
      setSelectedDriver(null);
      toast.success("Driver updated successfully");
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to update driver",
      );
    } finally {
      setIsSaving(false);
    }
  };

  const openConfirm = (driver: Driver, action: ConfirmAction) => {
    setConfirmDriver(driver);
    setConfirmAction(action);
    setConfirmOpen(true);
  };

  const closeConfirm = () => {
    setConfirmOpen(false);
    setConfirmAction(null);
    setConfirmDriver(null);
  };

  const handleConfirmAction = async () => {
    if (!confirmDriver || !confirmAction) return;

    const driver = confirmDriver;
    closeConfirm();
    setActionDriverId(driver.id);

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

      await loadDrivers({ silent: true });
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
      setActionDriverId(null);
    }
  };

  const columns: Column<Driver>[] = [
    { key: "id", header: "Driver ID", cell: (d) => <span className="font-mono text-xs">{d.id}</span>, sortable: true },
    {
      key: "name",
      header: "Name",
      cell: (d) => (
        <Link href={`/drivers/${d.id}`} className="font-medium text-primary hover:underline">
          {d.name}
        </Link>
      ),
      sortable: true,
    },
    { key: "phone", header: "Phone", cell: (d) => d.phone },
    { key: "vehicleType", header: "Vehicle", cell: (d) => capitalize(d.vehicleType) },
    { key: "vehicleNumber", header: "Vehicle No.", cell: (d) => <span className="font-mono text-xs">{d.vehicleNumber}</span> },
    { key: "rating", header: "Rating", cell: (d) => <span className="font-medium">⭐ {d.rating}</span>, sortable: true },
    { key: "totalTrips", header: "Trips", cell: (d) => d.totalTrips.toLocaleString(), sortable: true },
    { key: "earnings", header: "Earnings", cell: (d) => formatCurrency(d.earnings), sortable: true },
    { key: "status", header: "Status", cell: (d) => <StatusBadge status={d.status} /> },
    {
      key: "actions",
      header: "Actions",
      cell: (d) => (
        <DropdownMenu>
          <DropdownMenuTrigger render={<Button variant="ghost" size="icon" className="h-8 w-8" />}>
            <MoreHorizontal className="h-4 w-4" />
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem render={<Link href={`/drivers/${d.id}`} />}>
              <Eye className="mr-2 h-4 w-4" /> View Details
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => openEdit(d)}>
              <Pencil className="mr-2 h-4 w-4" /> Edit Driver
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            {d.status === "pending" && (
              <>
                <DropdownMenuItem
                  disabled={actionDriverId === d.id}
                  onClick={() => openConfirm(d, "approve")}
                >
                  <CheckCircle className="mr-2 h-4 w-4" /> Approve
                </DropdownMenuItem>
                <DropdownMenuItem
                  disabled={actionDriverId === d.id}
                  onClick={() => openConfirm(d, "reject")}
                >
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
                  disabled={actionDriverId === d.id || d.status === status}
                  onClick={() => openConfirm(d, action)}
                >
                  {label}
                </DropdownMenuItem>
              ))}
            </DropdownMenuGroup>
            {d.status === "suspended" && (
              <>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  disabled={actionDriverId === d.id}
                  onClick={() => openConfirm(d, "reactivate")}
                >
                  <RotateCcw className="mr-2 h-4 w-4" /> Reactivate
                </DropdownMenuItem>
              </>
            )}
          </DropdownMenuContent>
        </DropdownMenu>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader title="Driver Management" description="Manage drivers, documents, and verifications">
        <ButtonLink href="/vehicles/approval">Vehicle Approval</ButtonLink>
        <ExportButton filename="wavego-drivers" exportPath={driversExportPath} />
      </PageHeader>

      <div className="flex flex-col gap-4 sm:flex-row">
        <SearchBar
          placeholder="Search drivers..."
          value={search}
          onChange={setSearch}
          className="flex-1"
        />
        <Select value={statusFilter} onValueChange={(v) => v && setStatusFilter(v)}>
          <SelectTrigger className="w-full sm:w-40">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Status</SelectItem>
            <SelectItem value="online">Online</SelectItem>
            <SelectItem value="offline">Offline</SelectItem>
            <SelectItem value="busy">Busy</SelectItem>
            <SelectItem value="pending">Pending</SelectItem>
            <SelectItem value="suspended">Suspended</SelectItem>
            <SelectItem value="rejected">Rejected</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <DataTable
        data={filteredDrivers}
        columns={columns}
        emptyTitle={isLoading ? "Loading drivers..." : "No drivers found"}
        emptyDescription={
          isLoading
            ? "Fetching driver data from the server."
            : "Try adjusting your search or filters."
        }
      />

      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Driver</DialogTitle>
            <DialogDescription>
              Update profile details for {selectedDriver?.name}
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-2">
            <div className="space-y-2">
              <Label htmlFor="edit-name">Full Name</Label>
              <Input
                id="edit-name"
                value={editForm.name}
                onChange={(e) =>
                  setEditForm((form) => ({ ...form, name: e.target.value }))
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-email">Email</Label>
              <Input
                id="edit-email"
                type="email"
                value={editForm.email}
                onChange={(e) =>
                  setEditForm((form) => ({ ...form, email: e.target.value }))
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-phone">Phone</Label>
              <Input
                id="edit-phone"
                value={editForm.phone}
                onChange={(e) =>
                  setEditForm((form) => ({ ...form, phone: e.target.value }))
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-city">City</Label>
              <Input
                id="edit-city"
                value={editForm.city}
                onChange={(e) =>
                  setEditForm((form) => ({ ...form, city: e.target.value }))
                }
              />
            </div>
          </div>
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
              {confirmAction && confirmDriver
                ? confirmConfig[confirmAction].description(confirmDriver.name)
                : null}
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
              disabled={actionDriverId === confirmDriver?.id}
            >
              {confirmAction ? confirmConfig[confirmAction].button : "Confirm"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
