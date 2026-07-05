"use client";

import { useCallback, useEffect, useState, use } from "react";
import { notFound } from "next/navigation";
import { ArrowLeft, Pencil, Ban, UserX, RotateCcw, CheckCircle, Star } from "lucide-react";
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
import { User } from "@/types";
import { formatCurrency, formatDate, formatDateTime, capitalize } from "@/lib/format";
import {
  activateUser,
  blockUser,
  fetchUser,
  fetchUserActivityLogs,
  fetchUserRides,
  fetchUserStudentPass,
  fetchUserSubscription,
  fetchUserSupportTickets,
  fetchUserWallet,
  resetUser,
  suspendUser,
  updateUser,
  UserActivityLog,
  UserRide,
  UserStudentPassDetail,
  UserSubscriptionDetail,
  UserSupportTicket,
  WalletTransaction,
} from "@/lib/users-api";
import { resolveMediaUrl } from "@/lib/api";
import { toast } from "sonner";
import { useAutoRefresh } from "@/hooks/use-auto-refresh";
import {
  createUserFormData,
  UserEditFormFields,
  UserFormData,
} from "@/components/users/user-edit-form-fields";

type ConfirmAction = "activate" | "unblock" | "suspend" | "block" | "reset";

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
  reset: {
    title: "Reset Account",
    description: (name) =>
      `Reset ${name}'s account? Wallet balance will be set to ₹0 and status will become active.`,
    button: "Reset Account",
    destructive: true,
  },
};

function buildUserUpdatePayload(form: UserFormData) {
  return {
    name: form.name.trim(),
    mobile: form.mobile.trim(),
    email: form.email.trim(),
    city: form.city.trim(),
    registrationDate: form.registrationDate,
    status: form.status,
  };
}

export default function UserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const [user, setUser] = useState<User | null>(null);
  const [userRides, setUserRides] = useState<UserRide[]>([]);
  const [walletTransactions, setWalletTransactions] = useState<WalletTransaction[]>([]);
  const [supportTickets, setSupportTickets] = useState<UserSupportTicket[]>([]);
  const [activityLogs, setActivityLogs] = useState<UserActivityLog[]>([]);
  const [subscription, setSubscription] = useState<UserSubscriptionDetail | null>(null);
  const [studentPass, setStudentPass] = useState<UserStudentPassDetail | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [notFoundState, setNotFoundState] = useState(false);
  const [editOpen, setEditOpen] = useState(false);
  const [editForm, setEditForm] = useState<UserFormData>({
    name: "",
    mobile: "",
    email: "",
    city: "",
    registrationDate: "",
    status: "active",
  });
  const [isSaving, setIsSaving] = useState(false);
  const [isActionLoading, setIsActionLoading] = useState(false);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [confirmAction, setConfirmAction] = useState<ConfirmAction | null>(null);

  const loadUserData = useCallback(async (options?: { silent?: boolean }) => {
    if (!options?.silent) {
      setIsLoading(true);
      setNotFoundState(false);
    }

    try {
      const [userData, rides, wallet, tickets, logs, subscriptionData, studentPassData] =
        await Promise.all([
        fetchUser(id),
        fetchUserRides(id),
        fetchUserWallet(id),
        fetchUserSupportTickets(id),
        fetchUserActivityLogs(id),
        fetchUserSubscription(id),
        fetchUserStudentPass(id),
      ]);

      setUser(userData);
      setUserRides(rides);
      setWalletTransactions(wallet.transactions);
      setSupportTickets(tickets);
      setActivityLogs(logs);
      setSubscription(subscriptionData.subscription);
      setStudentPass(studentPassData.application);
    } catch (error) {
      if (error instanceof Error && error.message.includes("not found")) {
        setNotFoundState(true);
      } else if (!options?.silent) {
        toast.error(
          error instanceof Error ? error.message : "Failed to load user details",
        );
      }
    } finally {
      if (!options?.silent) {
        setIsLoading(false);
      }
    }
  }, [id]);

  useEffect(() => {
    void loadUserData();
  }, [loadUserData]);

  useAutoRefresh(() => loadUserData({ silent: true }));

  if (notFoundState) notFound();

  const openEdit = () => {
    if (!user) return;
    setEditForm(createUserFormData(user));
    setEditOpen(true);
  };

  const handleEdit = async () => {
    if (!user) return;

    if (!editForm.name.trim() || !editForm.email.trim()) {
      toast.error("Name and email are required");
      return;
    }

    setIsSaving(true);
    try {
      await updateUser(user.id, buildUserUpdatePayload(editForm));
      await loadUserData({ silent: true });
      setEditOpen(false);
      toast.success("User updated successfully");
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to update user",
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
    if (!user || !confirmAction) return;

    closeConfirm();
    setIsActionLoading(true);

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
      } else if (confirmAction === "block") {
        await blockUser(user.id);
        toast.success(`${user.name} has been blocked`);
      } else {
        await resetUser(user.id);
        toast.success(`${user.name}'s account has been reset`);
      }

      await loadUserData({ silent: true });
    } catch (error) {
      const fallback =
        confirmAction === "activate"
          ? "Failed to activate user"
          : confirmAction === "unblock"
            ? "Failed to unblock user"
            : confirmAction === "suspend"
              ? "Failed to suspend user"
              : confirmAction === "block"
                ? "Failed to block user"
                : "Failed to reset account";
      toast.error(error instanceof Error ? error.message : fallback);
    } finally {
      setIsActionLoading(false);
    }
  };

  if (isLoading || !user) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <ButtonLink variant="ghost" size="icon" href="/users">
            <ArrowLeft className="h-4 w-4" />
          </ButtonLink>
          <PageHeader title="Loading user..." description={`User ID: ${id}`} />
        </div>
        <div className="rounded-xl border bg-card p-6 text-sm text-muted-foreground">
          Fetching user details...
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <ButtonLink variant="ghost" size="icon" href="/users">
          <ArrowLeft className="h-4 w-4" />
        </ButtonLink>
        <PageHeader title={user.name} description={`User ID: ${user.id}`}>
          <Button variant="outline" size="sm" onClick={openEdit} disabled={isActionLoading}>
            <Pencil className="mr-2 h-4 w-4" /> Edit
          </Button>
          {user.status === "suspended" || user.status === "inactive" ? (
            <Button
              variant="outline"
              size="sm"
              onClick={() => openConfirm("activate")}
              disabled={isActionLoading}
            >
              <CheckCircle className="mr-2 h-4 w-4" /> Activate
            </Button>
          ) : user.status === "blocked" ? (
            <Button
              variant="outline"
              size="sm"
              onClick={() => openConfirm("unblock")}
              disabled={isActionLoading}
            >
              <CheckCircle className="mr-2 h-4 w-4" /> Unblock
            </Button>
          ) : (
            <Button
              variant="outline"
              size="sm"
              onClick={() => openConfirm("suspend")}
              disabled={isActionLoading}
            >
              <Ban className="mr-2 h-4 w-4" /> Suspend
            </Button>
          )}
          {user.status !== "blocked" && (
            <Button
              variant="destructive"
              size="sm"
              onClick={() => openConfirm("block")}
              disabled={isActionLoading}
            >
              <UserX className="mr-2 h-4 w-4" /> Block
            </Button>
          )}
          <Button
            variant="outline"
            size="sm"
            onClick={() => openConfirm("reset")}
            disabled={isActionLoading}
          >
            <RotateCcw className="mr-2 h-4 w-4" /> Reset Account
          </Button>
        </PageHeader>
      </div>

      <div className="flex items-center gap-4 rounded-xl border bg-card p-6">
        <Avatar className="h-16 w-16">
          <AvatarFallback className="bg-primary text-primary-foreground text-xl">
            {user.name.split(" ").map((n) => n[0]).join("")}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1">
          <div className="flex items-center gap-3">
            <h2 className="text-xl font-semibold">{user.name}</h2>
            <StatusBadge status={user.status} />
          </div>
          <p className="text-sm text-muted-foreground">
            {user.email || "—"} · {user.mobile || "—"}
          </p>
        </div>
        <div className="grid grid-cols-4 gap-6 text-center">
          <div>
            <p className="text-2xl font-bold">{user.totalRides}</p>
            <p className="text-xs text-muted-foreground">Total Rides</p>
          </div>
          <div>
            <p className="text-2xl font-bold flex items-center justify-center gap-1">
              <Star className="h-5 w-5 text-amber-500" /> {user.rating.toFixed(1)}
            </p>
            <p className="text-xs text-muted-foreground">Rating</p>
          </div>
          <div>
            <p className="text-2xl font-bold">{formatCurrency(user.walletBalance)}</p>
            <p className="text-xs text-muted-foreground">Wallet Balance</p>
          </div>
          <div>
            <p className="text-2xl font-bold">{user.city || "—"}</p>
            <p className="text-xs text-muted-foreground">City</p>
          </div>
        </div>
      </div>

      <Tabs defaultValue="profile">
        <TabsList>
          <TabsTrigger value="profile">Profile</TabsTrigger>
          <TabsTrigger value="rides">Ride History</TabsTrigger>
          <TabsTrigger value="wallet">Wallet</TabsTrigger>
          <TabsTrigger value="subscription">Subscription</TabsTrigger>
          <TabsTrigger value="student-pass">Student Pass</TabsTrigger>
          <TabsTrigger value="support">Support Tickets</TabsTrigger>
          <TabsTrigger value="activity">Activity Logs</TabsTrigger>
        </TabsList>

        <TabsContent value="profile" className="mt-6">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle>Profile Information</CardTitle>
              <Button variant="outline" size="sm" onClick={openEdit}>
                <Pencil className="mr-2 h-4 w-4" /> Edit Profile
              </Button>
            </CardHeader>
            <CardContent className="grid gap-4 sm:grid-cols-2">
              {[
                ["Full Name", user.name],
                ["Email", user.email],
                ["Mobile", user.mobile],
                ["Emergency Contact Name", user.emergencyContactName || "—"],
                ["Emergency Contact Phone", user.emergencyContactPhone || "—"],
                ["City", user.city],
                ["Registration Date", formatDate(user.registrationDate)],
                ["Status", capitalize(user.status)],
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
              {userRides.length === 0 ? (
                <p className="text-sm text-muted-foreground">No rides found for this user.</p>
              ) : (
                <div className="w-full overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Ride ID</TableHead>
                      <TableHead>Route</TableHead>
                      <TableHead>Fare</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Date</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {userRides.map((ride) => (
                      <TableRow key={ride.id}>
                        <TableCell className="font-mono text-xs whitespace-nowrap">{ride.id}</TableCell>
                        <TableCell>
                          <span className="text-sm block max-w-[520px] truncate" title={ride.pickupLocation}>
                            {ride.pickupLocation}
                          </span>
                          <span className="mx-1 text-muted-foreground">→</span>
                          <span className="text-sm block max-w-[520px] truncate" title={ride.dropLocation}>
                            {ride.dropLocation}
                          </span>
                        </TableCell>
                        <TableCell className="whitespace-nowrap">{formatCurrency(ride.fare)}</TableCell>
                        <TableCell><StatusBadge status={ride.status} /></TableCell>
                        <TableCell className="whitespace-nowrap">{formatDateTime(ride.date)}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="wallet" className="mt-6">
          <Card>
            <CardHeader><CardTitle>Wallet Transactions</CardTitle></CardHeader>
            <CardContent>
              <div className="mb-4 rounded-lg bg-primary/5 p-4">
                <p className="text-sm text-muted-foreground">Current Balance</p>
                <p className="text-3xl font-bold text-primary">{formatCurrency(user.walletBalance)}</p>
              </div>
              {walletTransactions.length === 0 ? (
                <p className="text-sm text-muted-foreground">No wallet transactions found.</p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Date</TableHead>
                      <TableHead>Description</TableHead>
                      <TableHead>Amount</TableHead>
                      <TableHead>Status</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {walletTransactions.map((tx) => (
                      <TableRow key={tx.id}>
                        <TableCell>{formatDate(tx.date)}</TableCell>
                        <TableCell>{tx.description}</TableCell>
                        <TableCell className={tx.amount > 0 ? "text-emerald-600" : "text-red-600"}>
                          {tx.amount > 0 ? "+" : ""}{formatCurrency(Math.abs(tx.amount))}
                        </TableCell>
                        <TableCell><StatusBadge status={tx.status} /></TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="subscription" className="mt-6">
          <Card>
            <CardHeader>
              <CardTitle>Subscription</CardTitle>
            </CardHeader>
            <CardContent>
              {!subscription ? (
                <p className="text-sm text-muted-foreground">
                  No active subscription plan for this user.
                </p>
              ) : (
                <div className="space-y-4">
                  <div className="flex flex-wrap items-center gap-3">
                    <h3 className="text-lg font-semibold">{subscription.plan.name}</h3>
                    <StatusBadge status={subscription.status} />
                  </div>
                  <div className="grid gap-4 sm:grid-cols-2">
                    {[
                      ["Plan slug", subscription.plan.slug],
                      ["Price", `${subscription.plan.price_label} ${subscription.plan.period_label}`],
                      ["Ride discount", `${subscription.plan.ride_discount_percent}%`],
                      ["Subscribed on", subscription.started_at ? formatDate(subscription.started_at) : "—"],
                      ["Expires", subscription.expires_at ? formatDate(subscription.expires_at) : "—"],
                      ["Description", subscription.plan.description || "—"],
                    ].map(([label, value]) => (
                      <div key={label} className="rounded-lg border p-4">
                        <p className="text-xs text-muted-foreground">{label}</p>
                        <p className="mt-1 font-medium">{value}</p>
                      </div>
                    ))}
                  </div>
                  {subscription.plan.benefits.length > 0 ? (
                    <div className="rounded-lg border p-4">
                      <p className="text-xs text-muted-foreground">Benefits</p>
                      <ul className="mt-2 space-y-1 text-sm">
                        {subscription.plan.benefits.map((benefit) => (
                          <li key={benefit}>• {benefit}</li>
                        ))}
                      </ul>
                    </div>
                  ) : null}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="student-pass" className="mt-6">
          <Card>
            <CardHeader>
              <CardTitle>Student Pass</CardTitle>
            </CardHeader>
            <CardContent>
              {!studentPass || studentPass.status !== "approved" ? (
                <p className="text-sm text-muted-foreground">
                  No active student pass for this user.
                </p>
              ) : (
                <div className="space-y-4">
                  <div className="flex flex-wrap items-center gap-3">
                    <StatusBadge status="approved" />
                    <p className="text-sm font-medium text-primary">
                      {studentPass.discount_percent}% ride discount active
                    </p>
                  </div>
                  <div className="grid gap-4 sm:grid-cols-2">
                    {[
                      ["College", studentPass.college_name],
                      ["Aadhar", studentPass.aadhar_number],
                      ["Verified on", studentPass.verified_at ? formatDate(studentPass.verified_at) : "—"],
                      ["Applied on", studentPass.created_at ? formatDate(studentPass.created_at) : "—"],
                    ].map(([label, value]) => (
                      <div key={label} className="rounded-lg border p-4">
                        <p className="text-xs text-muted-foreground">{label}</p>
                        <p className="mt-1 font-medium">{value}</p>
                      </div>
                    ))}
                  </div>
                  <div className="grid gap-4 sm:grid-cols-2">
                    {studentPass.aadhar_photo_url ? (
                      <a
                        href={resolveMediaUrl(studentPass.aadhar_photo_url) ?? "#"}
                        target="_blank"
                        rel="noreferrer"
                        className="block"
                      >
                        <p className="mb-2 text-xs text-muted-foreground">Aadhar card</p>
                        <img
                          src={resolveMediaUrl(studentPass.aadhar_photo_url) ?? ""}
                          alt="Aadhar"
                          className="rounded-lg border"
                        />
                      </a>
                    ) : null}
                    {studentPass.student_id_photo_url ? (
                      <a
                        href={resolveMediaUrl(studentPass.student_id_photo_url) ?? "#"}
                        target="_blank"
                        rel="noreferrer"
                        className="block"
                      >
                        <p className="mb-2 text-xs text-muted-foreground">Student ID</p>
                        <img
                          src={resolveMediaUrl(studentPass.student_id_photo_url) ?? ""}
                          alt="Student ID"
                          className="rounded-lg border"
                        />
                      </a>
                    ) : null}
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="support" className="mt-6">
          <Card>
            <CardHeader><CardTitle>Support Tickets</CardTitle></CardHeader>
            <CardContent>
              {supportTickets.length === 0 ? (
                <p className="text-sm text-muted-foreground">No support tickets found.</p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Ticket ID</TableHead>
                      <TableHead>Subject</TableHead>
                      <TableHead>Priority</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Date</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {supportTickets.map((ticket) => (
                      <TableRow key={ticket.id}>
                        <TableCell className="font-mono text-xs">{ticket.id}</TableCell>
                        <TableCell>{ticket.subject}</TableCell>
                        <TableCell><StatusBadge status={ticket.priority} /></TableCell>
                        <TableCell><StatusBadge status={ticket.status} /></TableCell>
                        <TableCell>{formatDate(ticket.createdAt)}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="activity" className="mt-6">
          <Card>
            <CardHeader><CardTitle>Activity Logs</CardTitle></CardHeader>
            <CardContent className="space-y-4">
              {activityLogs.length === 0 ? (
                <p className="text-sm text-muted-foreground">No activity logs found.</p>
              ) : (
                activityLogs.map((log) => (
                  <div
                    key={log.id}
                    className="flex items-center justify-between border-b pb-3 last:border-0"
                  >
                    <span className="text-sm">{log.action}</span>
                    <span className="text-xs text-muted-foreground">
                      {formatDateTime(log.timestamp)}
                    </span>
                  </div>
                ))
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>Edit User</DialogTitle>
            <DialogDescription>
              Update profile details for {user.name}
            </DialogDescription>
          </DialogHeader>
          <UserEditFormFields
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
              {confirmAction ? confirmConfig[confirmAction].description(user.name) : null}
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
