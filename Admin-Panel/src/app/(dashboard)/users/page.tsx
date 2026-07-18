"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { MoreHorizontal, Eye, Pencil, Ban, UserX, CheckCircle, Trash2, RefreshCw } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { SearchBar } from "@/components/shared/search-bar";
import { ExportButton } from "@/components/shared/export-button";
import { DataTable, Column } from "@/components/shared/data-table";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
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
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { User } from "@/types";
import { formatCurrency, formatDate, formatPublicId } from "@/lib/format";
import {
  activateUser,
  blockUser,
  deleteUser,
  fetchUsers,
  suspendUser,
  updateUser,
} from "@/lib/users-api";
import { toast } from "sonner";
import { useAuth } from "@/components/providers/auth-provider";

type UserFormData = {
  name: string;
  mobile: string;
  email: string;
  gender: string;
};

type ConfirmAction = "activate" | "unblock" | "suspend" | "block" | "delete";

const confirmConfig: Record<
  ConfirmAction,
  { title: string; description: (name: string) => string; button: string; destructive?: boolean }
> = {
  activate: {
    title: "Activate User",
    description: (name) =>
      `Are you sure you want to activate ${name}? The user will regain full access to their account.`,
    button: "Activate User",
  },
  unblock: {
    title: "Unblock User",
    description: (name) =>
      `Are you sure you want to unblock ${name}? The user will be able to access their account again.`,
    button: "Unblock User",
  },
  suspend: {
    title: "Suspend User",
    description: (name) =>
      `Are you sure you want to suspend ${name}? The user will temporarily lose access until reactivated.`,
    button: "Suspend User",
  },
  block: {
    title: "Block User",
    description: (name) =>
      `Are you sure you want to block ${name}? This will restrict account access immediately.`,
    button: "Block User",
    destructive: true,
  },
  delete: {
    title: "Delete User",
    description: (name) =>
      `Permanently delete ${name}'s account? They will need to sign up again from scratch. Ride history may be kept for records.`,
    button: "Delete User",
    destructive: true,
  },
};

function userToForm(user: User): UserFormData {
  return {
    name: user.name,
    mobile: user.mobile,
    email: user.email,
    gender: user.gender ?? "",
  };
}

function buildUserUpdatePayload(form: UserFormData) {
  return {
    name: form.name.trim(),
    mobile: form.mobile.trim(),
    email: form.email.trim(),
    gender: form.gender.trim(),
  };
}

export default function UsersPage() {
  const { isAuthenticated, isLoading: authLoading } = useAuth();
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [userList, setUserList] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [editOpen, setEditOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [editForm, setEditForm] = useState<UserFormData>({
    name: "",
    mobile: "",
    email: "",
    gender: "",
  });
  const [isSaving, setIsSaving] = useState(false);
  const [actionUserId, setActionUserId] = useState<string | null>(null);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [confirmAction, setConfirmAction] = useState<ConfirmAction | null>(null);
  const [confirmUser, setConfirmUser] = useState<User | null>(null);

  const loadUsers = useCallback(async (options?: { silent?: boolean }) => {
    if (!options?.silent) {
      setIsLoading(true);
    }

    try {
      const response = await fetchUsers({
        search: search || undefined,
        status: statusFilter,
        limit: 100,
      });
      setUserList(response.items);
    } catch (error) {
      if (!options?.silent) {
        toast.error(
          error instanceof Error ? error.message : "Failed to load users",
        );
        setUserList([]);
      }
    } finally {
      if (!options?.silent) {
        setIsLoading(false);
      }
    }
  }, [search, statusFilter]);

  useEffect(() => {
    if (authLoading) return;

    if (!isAuthenticated) {
      setUserList([]);
      setIsLoading(false);
      return;
    }

    const timer = setTimeout(() => {
      void loadUsers();
    }, 300);

    return () => clearTimeout(timer);
  }, [loadUsers, authLoading, isAuthenticated]);

  const filteredUsers = useMemo(() => userList, [userList]);

  const usersExportPath = useMemo(() => {
    const query = new URLSearchParams();
    if (search) query.set("search", search);
    if (statusFilter !== "all") query.set("status", statusFilter);
    const qs = query.toString();
    return `/api/v1/admin/users/export${qs ? `?${qs}` : ""}`;
  }, [search, statusFilter]);

  const openEdit = (user: User) => {
    setSelectedUser(user);
    setEditForm(userToForm(user));
    setEditOpen(true);
  };

  const handleEdit = async () => {
    if (!selectedUser) return;

    if (!editForm.name.trim() || !editForm.email.trim()) {
      toast.error("Name and email are required");
      return;
    }

    setIsSaving(true);
    try {
      await updateUser(selectedUser.id, buildUserUpdatePayload(editForm));
      await loadUsers({ silent: true });
      setEditOpen(false);
      setSelectedUser(null);
      toast.success("User updated successfully");
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to update user",
      );
    } finally {
      setIsSaving(false);
    }
  };

  const openConfirm = (user: User, action: ConfirmAction) => {
    setConfirmUser(user);
    setConfirmAction(action);
    setConfirmOpen(true);
  };

  const closeConfirm = () => {
    setConfirmOpen(false);
    setConfirmAction(null);
    setConfirmUser(null);
  };

  const handleConfirmAction = async () => {
    if (!confirmUser || !confirmAction) return;

    const user = confirmUser;
    closeConfirm();
    setActionUserId(user.id);

    try {
      if (confirmAction === "activate" || confirmAction === "unblock") {
        await activateUser(user.id);
        toast.success(
          confirmAction === "unblock"
            ? `${user.name} has been unblocked`
            : `${user.name} is now active`,
        );
      } else if (confirmAction === "suspend") {
        await suspendUser(user.id);
        toast.success(`${user.name} has been suspended`);
      } else if (confirmAction === "delete") {
        await deleteUser(user.id);
        toast.success(`${user.name} has been deleted`);
      } else {
        await blockUser(user.id);
        toast.success(`${user.name} has been blocked`);
      }

      await loadUsers({ silent: true });
    } catch (error) {
      const fallback =
        confirmAction === "activate"
          ? "Failed to activate user"
          : confirmAction === "unblock"
            ? "Failed to unblock user"
            : confirmAction === "suspend"
              ? "Failed to suspend user"
              : confirmAction === "delete"
                ? "Failed to delete user"
              : "Failed to block user";
      toast.error(error instanceof Error ? error.message : fallback);
    } finally {
      setActionUserId(null);
    }
  };

  const columns: Column<User>[] = [
    { key: "id", header: "User ID", cell: (u) => (
      <span className="font-mono text-xs" title={u.id}>{formatPublicId(u.publicId, u.id)}</span>
    ), sortable: true },
    { key: "name", header: "Name", cell: (u) => (
      <Link href={`/users/${u.id}`} className="font-medium text-primary hover:underline">
        {u.name}
      </Link>
    ), sortable: true },
    { key: "mobile", header: "Mobile", cell: (u) => u.mobile },
    { key: "email", header: "Email", cell: (u) => <span className="text-muted-foreground">{u.email}</span> },
    { key: "registrationDate", header: "Registered", cell: (u) => formatDate(u.registrationDate), sortable: true },
    { key: "totalRides", header: "Total Rides", cell: (u) => u.totalRides, sortable: true },
    { key: "rating", header: "Rating", cell: (u) => <span className="font-medium">⭐ {u.rating.toFixed(1)}</span>, sortable: true },
    { key: "walletBalance", header: "Wallet", cell: (u) => formatCurrency(u.walletBalance), sortable: true },
    { key: "status", header: "Status", cell: (u) => <StatusBadge status={u.status} /> },
    {
      key: "actions",
      header: "Actions",
      cell: (u) => (
        <div className="flex items-center gap-1">
          <DropdownMenu>
          <DropdownMenuTrigger render={<Button variant="ghost" size="icon" className="h-8 w-8" />}>
            <MoreHorizontal className="h-4 w-4" />
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem render={<Link href={`/users/${u.id}`} />}>
              <Eye className="mr-2 h-4 w-4" /> View Details
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => openEdit(u)}>
              <Pencil className="mr-2 h-4 w-4" /> Edit User
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            {u.status === "suspended" || u.status === "inactive" ? (
              <DropdownMenuItem
                disabled={actionUserId === u.id}
                onClick={() => openConfirm(u, "activate")}
              >
                <CheckCircle className="mr-2 h-4 w-4" /> Activate User
              </DropdownMenuItem>
            ) : (
              <DropdownMenuItem
                disabled={actionUserId === u.id}
                onClick={() => openConfirm(u, "suspend")}
              >
                <Ban className="mr-2 h-4 w-4" /> Suspend User
              </DropdownMenuItem>
            )}
            {u.status === "blocked" ? (
              <DropdownMenuItem
                disabled={actionUserId === u.id}
                onClick={() => openConfirm(u, "unblock")}
              >
                <CheckCircle className="mr-2 h-4 w-4" /> Unblock User
              </DropdownMenuItem>
            ) : (
              <DropdownMenuItem
                variant="destructive"
                disabled={actionUserId === u.id}
                onClick={() => openConfirm(u, "block")}
              >
                <UserX className="mr-2 h-4 w-4" /> Block User
              </DropdownMenuItem>
            )}
            <DropdownMenuSeparator />
            <DropdownMenuItem
              variant="destructive"
              disabled={actionUserId === u.id}
              onClick={() => openConfirm(u, "delete")}
            >
              <Trash2 className="mr-2 h-4 w-4" /> Delete User
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader title="User Management" description="Manage and monitor all registered users">
        <Button
          variant="outline"
          size="sm"
          onClick={() => void loadUsers()}
          disabled={isLoading}
        >
          <RefreshCw className={`mr-2 h-4 w-4 ${isLoading ? "animate-spin" : ""}`} />
          Refresh
        </Button>
        <ExportButton filename="wavego-users" exportPath={usersExportPath} />
      </PageHeader>

      <div className="flex flex-col gap-4 sm:flex-row">
        <SearchBar
          placeholder="Search by name, email, mobile, or ID..."
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
            <SelectItem value="active">Active</SelectItem>
            <SelectItem value="suspended">Suspended</SelectItem>
            <SelectItem value="blocked">Blocked</SelectItem>
            <SelectItem value="inactive">Inactive</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <DataTable
        data={filteredUsers}
        columns={columns}
        emptyTitle={isLoading ? "Loading users..." : "No users found"}
        emptyDescription={
          isLoading
            ? "Fetching user data from the server."
            : "Try adjusting your search or filters."
        }
      />

      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit User</DialogTitle>
            <DialogDescription>
              Update profile details for {selectedUser?.name}
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
              <Label htmlFor="edit-mobile">Mobile</Label>
              <Input
                id="edit-mobile"
                value={editForm.mobile}
                onChange={(e) =>
                  setEditForm((form) => ({ ...form, mobile: e.target.value }))
                }
              />
            </div>
            <div className="space-y-2">
              <Label>Gender</Label>
              <Select
                value={editForm.gender || "unset"}
                onValueChange={(value) =>
                  setEditForm((form) => ({
                    ...form,
                    gender: value === "unset" ? "" : value,
                  }))
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select gender" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="unset">Not set</SelectItem>
                  <SelectItem value="male">Male</SelectItem>
                  <SelectItem value="female">Female</SelectItem>
                  <SelectItem value="other">Other</SelectItem>
                </SelectContent>
              </Select>
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
              {confirmAction && confirmUser
                ? confirmConfig[confirmAction].description(confirmUser.name)
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
              disabled={actionUserId === confirmUser?.id}
            >
              {confirmAction ? confirmConfig[confirmAction].button : "Confirm"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
