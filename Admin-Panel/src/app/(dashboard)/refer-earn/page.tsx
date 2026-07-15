"use client";

import { useCallback, useEffect, useState } from "react";
import {
  Gift,
  Loader2,
  Save,
  Users,
  Car,
  MoreHorizontal,
  Pencil,
  RefreshCw,
  Wallet,
  Ban,
  RotateCcw,
  Eye,
} from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
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
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { DataTable, type Column } from "@/components/shared/data-table";
import { StatusBadge } from "@/components/shared/status-badge";
import {
  listReferralPrograms,
  updateReferralProgram,
  listReferralRewards,
  updateReferralReward,
  type ReferralAudience,
  type ReferralProgram,
  type ReferralReward,
  type ReferralRewardStatus,
} from "@/lib/referral-api";
import { formatCurrency, formatDateTime } from "@/lib/format";
import { toast } from "sonner";

type FormState = {
  isEnabled: boolean;
  requiredRides: string;
  rewardAmount: string;
  title: string;
  description: string;
  terms: string;
  shareMessage: string;
};

function toForm(program: ReferralProgram): FormState {
  return {
    isEnabled: program.isEnabled,
    requiredRides: String(program.requiredRides),
    rewardAmount: String(program.rewardAmount),
    title: program.title || "Refer & Earn",
    description: program.description || "",
    terms: program.terms || "",
    shareMessage: program.shareMessage || "",
  };
}

function ProgramForm({
  audience,
  form,
  saving,
  onChange,
  onSave,
}: {
  audience: ReferralAudience;
  form: FormState;
  saving: boolean;
  onChange: (updates: Partial<FormState>) => void;
  onSave: () => void;
}) {
  const label = audience === "USER" ? "User app" : "Driver app";
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          {audience === "USER" ? <Users className="h-5 w-5" /> : <Car className="h-5 w-5" />}
          {label} referral rules
        </CardTitle>
        <CardDescription>
          When someone joins with a share code and completes the required rides, the referrer gets the reward
          in their wallet.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-5">
        <label className="flex items-center gap-3 text-sm font-medium">
          <input
            type="checkbox"
            className="h-4 w-4 accent-primary"
            checked={form.isEnabled}
            onChange={(e) => onChange({ isEnabled: e.target.checked })}
          />
          Enable Refer & Earn for {label.toLowerCase()}
        </label>

        <div className="grid gap-4 sm:grid-cols-2">
          <div className="space-y-2">
            <Label>Rides required (by referred person)</Label>
            <Input
              type="number"
              min={1}
              value={form.requiredRides}
              onChange={(e) => onChange({ requiredRides: e.target.value })}
              placeholder="e.g. 5"
            />
          </div>
          <div className="space-y-2">
            <Label>Reward amount (₹) for referrer</Label>
            <Input
              type="number"
              min={0}
              step="0.01"
              value={form.rewardAmount}
              onChange={(e) => onChange({ rewardAmount: e.target.value })}
              placeholder="e.g. 100"
            />
          </div>
        </div>

        <div className="space-y-2">
          <Label>Title</Label>
          <Input value={form.title} onChange={(e) => onChange({ title: e.target.value })} />
        </div>
        <div className="space-y-2">
          <Label>Description (shown in app)</Label>
          <Textarea
            rows={3}
            value={form.description}
            onChange={(e) => onChange({ description: e.target.value })}
          />
        </div>
        <div className="space-y-2">
          <Label>Share message template</Label>
          <Textarea
            rows={2}
            value={form.shareMessage}
            onChange={(e) => onChange({ shareMessage: e.target.value })}
            placeholder="Use {code} where the invite code should appear"
          />
          <p className="text-xs text-muted-foreground">
            Placeholders: {"{code}"} (invite code), {"{rides}"} (required rides), {"{reward}"} (₹ amount).
            Users see the filled message before sharing.
          </p>
        </div>
        <div className="space-y-2">
          <Label>Terms</Label>
          <Textarea rows={3} value={form.terms} onChange={(e) => onChange({ terms: e.target.value })} />
        </div>

        <Button onClick={onSave} disabled={saving}>
          {saving ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Save className="mr-2 h-4 w-4" />}
          Save {label} rules
        </Button>
      </CardContent>
    </Card>
  );
}

function PersonCell({ name, phone, code }: { name: string; phone: string; code?: string }) {
  return (
    <div className="min-w-[140px]">
      <p className="font-medium leading-tight">{name}</p>
      <p className="text-xs text-muted-foreground">{phone || "—"}</p>
      {code ? <p className="mt-0.5 font-mono text-xs text-primary">{code}</p> : null}
    </div>
  );
}

export default function ReferEarnPage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState<ReferralAudience | null>(null);
  const [userForm, setUserForm] = useState<FormState | null>(null);
  const [driverForm, setDriverForm] = useState<FormState | null>(null);

  const [trackingLoading, setTrackingLoading] = useState(false);
  const [rewards, setRewards] = useState<ReferralReward[]>([]);
  const [summary, setSummary] = useState({
    total: 0,
    pending: 0,
    paid: 0,
    cancelled: 0,
    totalPaidAmount: 0,
  });
  const [audienceFilter, setAudienceFilter] = useState<ReferralAudience | "ALL">("ALL");
  const [statusFilter, setStatusFilter] = useState<ReferralRewardStatus | "ALL">("ALL");
  const [actionLoading, setActionLoading] = useState<string | null>(null);

  const [editOpen, setEditOpen] = useState(false);
  const [viewOpen, setViewOpen] = useState(false);
  const [selected, setSelected] = useState<ReferralReward | null>(null);
  const [editRides, setEditRides] = useState("");
  const [editAmount, setEditAmount] = useState("");

  const loadPrograms = useCallback(async () => {
    setLoading(true);
    try {
      const programs = await listReferralPrograms();
      const user = programs.find((p) => p.audience === "USER");
      const driver = programs.find((p) => p.audience === "DRIVER");
      if (user) setUserForm(toForm(user));
      if (driver) setDriverForm(toForm(driver));
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to load referral programs");
    } finally {
      setLoading(false);
    }
  }, []);

  const loadRewards = useCallback(async () => {
    setTrackingLoading(true);
    try {
      const res = await listReferralRewards({
        audience: audienceFilter,
        status: statusFilter,
      });
      setRewards(res.items);
      setSummary(res.summary);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to load referral tracking");
    } finally {
      setTrackingLoading(false);
    }
  }, [audienceFilter, statusFilter]);

  useEffect(() => {
    void loadPrograms();
  }, [loadPrograms]);

  useEffect(() => {
    void loadRewards();
  }, [loadRewards]);

  const save = async (audience: ReferralAudience) => {
    const form = audience === "USER" ? userForm : driverForm;
    if (!form) return;
    const rides = Number(form.requiredRides);
    const amount = Number(form.rewardAmount);
    if (!Number.isFinite(rides) || rides < 1) {
      toast.error("Required rides must be at least 1");
      return;
    }
    if (!Number.isFinite(amount) || amount < 0) {
      toast.error("Enter a valid reward amount");
      return;
    }

    setSaving(audience);
    try {
      const updated = await updateReferralProgram(audience, {
        isEnabled: form.isEnabled,
        requiredRides: rides,
        rewardAmount: amount,
        title: form.title.trim() || "Refer & Earn",
        description: form.description,
        terms: form.terms,
        shareMessage: form.shareMessage,
      });
      if (audience === "USER") setUserForm(toForm(updated));
      else setDriverForm(toForm(updated));
      toast.success(`${audience === "USER" ? "User" : "Driver"} referral rules saved`);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to save");
    } finally {
      setSaving(null);
    }
  };

  const runAction = async (
    reward: ReferralReward,
    action: "refresh" | "pay_now" | "cancel" | "reopen",
  ) => {
    setActionLoading(reward.id);
    try {
      await updateReferralReward(reward.id, { action });
      toast.success(
        action === "pay_now"
          ? "Reward credited to referrer wallet"
          : action === "cancel"
            ? "Referral cancelled"
            : action === "reopen"
              ? "Referral reopened"
              : "Progress refreshed",
      );
      await loadRewards();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Action failed");
    } finally {
      setActionLoading(null);
    }
  };

  const openEdit = (reward: ReferralReward) => {
    setSelected(reward);
    setEditRides(String(reward.requiredRides));
    setEditAmount(String(reward.rewardAmount));
    setEditOpen(true);
  };

  const openView = (reward: ReferralReward) => {
    setSelected(reward);
    setViewOpen(true);
  };

  const saveEdit = async () => {
    if (!selected) return;
    const rides = Number(editRides);
    const amount = Number(editAmount);
    if (!Number.isFinite(rides) || rides < 1) {
      toast.error("Required rides must be at least 1");
      return;
    }
    if (!Number.isFinite(amount) || amount < 0) {
      toast.error("Enter a valid reward amount");
      return;
    }
    setActionLoading(selected.id);
    try {
      await updateReferralReward(selected.id, {
        requiredRides: rides,
        rewardAmount: amount,
      });
      toast.success("Referral updated");
      setEditOpen(false);
      await loadRewards();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to update");
    } finally {
      setActionLoading(null);
    }
  };

  const columns: Column<ReferralReward>[] = [
    {
      key: "audience",
      header: "Type",
      cell: (r) => (r.audience === "USER" ? "User" : "Driver"),
    },
    {
      key: "referrer",
      header: "Code owner (gets reward)",
      cell: (r) => (
        <PersonCell name={r.referrer.name} phone={r.referrer.phone} code={r.referrer.inviteCode} />
      ),
    },
    {
      key: "referee",
      header: "Used by (referred)",
      cell: (r) => <PersonCell name={r.referee.name} phone={r.referee.phone} />,
    },
    {
      key: "progress",
      header: "Rides",
      cell: (r) => (
        <span className="font-medium">
          {r.ridesCompleted}/{r.requiredRides}
        </span>
      ),
    },
    {
      key: "reward",
      header: "Reward",
      cell: (r) => formatCurrency(r.rewardAmount),
    },
    {
      key: "when",
      header: "Wallet credit",
      cell: (r) => <span className="text-sm text-muted-foreground">{r.willCreditWhen}</span>,
    },
    {
      key: "status",
      header: "Status",
      cell: (r) => <StatusBadge status={r.status.toLowerCase()} />,
    },
    {
      key: "created",
      header: "Applied",
      cell: (r) => (r.createdAt ? formatDateTime(r.createdAt) : "—"),
    },
    {
      key: "actions",
      header: "Actions",
      cell: (reward) => (
        <DropdownMenu>
          <DropdownMenuTrigger
            render={<Button variant="ghost" size="icon" className="h-8 w-8" />}
            disabled={actionLoading === reward.id}
          >
            {actionLoading === reward.id ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <MoreHorizontal className="h-4 w-4" />
            )}
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-52">
            <DropdownMenuItem onClick={() => openView(reward)}>
              <Eye className="mr-2 h-4 w-4" /> View details
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => openEdit(reward)}>
              <Pencil className="mr-2 h-4 w-4" /> Edit rides / amount
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => void runAction(reward, "refresh")}>
              <RefreshCw className="mr-2 h-4 w-4" /> Refresh progress
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            {reward.status === "PENDING" ? (
              <>
                <DropdownMenuItem onClick={() => void runAction(reward, "pay_now")}>
                  <Wallet className="mr-2 h-4 w-4" /> Pay now to wallet
                </DropdownMenuItem>
                <DropdownMenuItem
                  className="text-destructive"
                  onClick={() => void runAction(reward, "cancel")}
                >
                  <Ban className="mr-2 h-4 w-4" /> Cancel
                </DropdownMenuItem>
              </>
            ) : null}
            {reward.status === "CANCELLED" ? (
              <DropdownMenuItem onClick={() => void runAction(reward, "reopen")}>
                <RotateCcw className="mr-2 h-4 w-4" /> Reopen
              </DropdownMenuItem>
            ) : null}
          </DropdownMenuContent>
        </DropdownMenu>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Refer & Earn"
        description="Set reward rules, track who used whose code, ride progress, and when wallet credits happen."
      />

      <Tabs defaultValue="tracking">
        <TabsList>
          <TabsTrigger value="tracking">
            <Gift className="mr-2 h-4 w-4" />
            Tracking
          </TabsTrigger>
          <TabsTrigger value="rules">
            <Save className="mr-2 h-4 w-4" />
            Rules
          </TabsTrigger>
        </TabsList>

        <TabsContent value="tracking" className="mt-4 space-y-4">
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>Total referrals</CardDescription>
                <CardTitle className="text-2xl">{summary.total}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>Pending</CardDescription>
                <CardTitle className="text-2xl">{summary.pending}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>Paid</CardDescription>
                <CardTitle className="text-2xl">{summary.paid}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>Total paid out</CardDescription>
                <CardTitle className="text-2xl">{formatCurrency(summary.totalPaidAmount)}</CardTitle>
              </CardHeader>
            </Card>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <Select
              value={audienceFilter}
              onValueChange={(v) => v && setAudienceFilter(v as ReferralAudience | "ALL")}
            >
              <SelectTrigger className="w-[140px]">
                <SelectValue placeholder="Audience" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="ALL">All types</SelectItem>
                <SelectItem value="USER">Users</SelectItem>
                <SelectItem value="DRIVER">Drivers</SelectItem>
              </SelectContent>
            </Select>
            <Select
              value={statusFilter}
              onValueChange={(v) => v && setStatusFilter(v as ReferralRewardStatus | "ALL")}
            >
              <SelectTrigger className="w-[140px]">
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="ALL">All status</SelectItem>
                <SelectItem value="PENDING">Pending</SelectItem>
                <SelectItem value="PAID">Paid</SelectItem>
                <SelectItem value="CANCELLED">Cancelled</SelectItem>
              </SelectContent>
            </Select>
            <Button variant="outline" onClick={() => void loadRewards()} disabled={trackingLoading}>
              {trackingLoading ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              ) : (
                <RefreshCw className="mr-2 h-4 w-4" />
              )}
              Refresh
            </Button>
          </div>

          {trackingLoading && rewards.length === 0 ? (
            <div className="flex items-center justify-center py-16 text-muted-foreground">
              <Loader2 className="mr-2 h-5 w-5 animate-spin" />
              Loading referral tracking…
            </div>
          ) : (
            <DataTable
              data={rewards}
              columns={columns}
              emptyTitle="No referrals yet"
              emptyDescription="When someone applies a referral code, it will show here with ride progress."
            />
          )}
        </TabsContent>

        <TabsContent value="rules" className="mt-4 space-y-4">
          {loading || !userForm || !driverForm ? (
            <div className="flex items-center justify-center py-20 text-muted-foreground">
              <Loader2 className="mr-2 h-5 w-5 animate-spin" />
              Loading referral settings…
            </div>
          ) : (
            <Tabs defaultValue="user">
              <TabsList>
                <TabsTrigger value="user">
                  <Users className="mr-2 h-4 w-4" />
                  Users
                </TabsTrigger>
                <TabsTrigger value="driver">
                  <Car className="mr-2 h-4 w-4" />
                  Drivers
                </TabsTrigger>
              </TabsList>
              <TabsContent value="user" className="mt-4">
                <ProgramForm
                  audience="USER"
                  form={userForm}
                  saving={saving === "USER"}
                  onChange={(u) => setUserForm((prev) => (prev ? { ...prev, ...u } : prev))}
                  onSave={() => void save("USER")}
                />
              </TabsContent>
              <TabsContent value="driver" className="mt-4">
                <ProgramForm
                  audience="DRIVER"
                  form={driverForm}
                  saving={saving === "DRIVER"}
                  onChange={(u) => setDriverForm((prev) => (prev ? { ...prev, ...u } : prev))}
                  onSave={() => void save("DRIVER")}
                />
              </TabsContent>
            </Tabs>
          )}

          <Card className="border-dashed">
            <CardContent className="flex items-start gap-3 pt-6 text-sm text-muted-foreground">
              <Gift className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
              <p>
                Example: set <strong>5 rides</strong> and <strong>₹100</strong> — when a friend joins with a
                share code and finishes 5 rides, the person who shared earns ₹100 in their wallet
                automatically. Tracking tab shows every code application and progress.
              </p>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      <Dialog open={viewOpen} onOpenChange={setViewOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Referral details</DialogTitle>
            <DialogDescription>Who referred whom, progress, and payout timing.</DialogDescription>
          </DialogHeader>
          {selected ? (
            <div className="grid gap-3 text-sm">
              <div className="grid grid-cols-2 gap-2">
                <span className="text-muted-foreground">Type</span>
                <span>{selected.audience === "USER" ? "User" : "Driver"}</span>
                <span className="text-muted-foreground">Status</span>
                <span>
                  <StatusBadge status={selected.status.toLowerCase()} />
                </span>
                <span className="text-muted-foreground">Code owner</span>
                <span>
                  {selected.referrer.name} ({selected.referrer.phone || "—"})
                  <br />
                  <span className="font-mono text-xs">{selected.referrer.inviteCode}</span>
                </span>
                <span className="text-muted-foreground">Used by</span>
                <span>
                  {selected.referee.name} ({selected.referee.phone || "—"})
                </span>
                <span className="text-muted-foreground">Rides</span>
                <span>
                  {selected.ridesCompleted} / {selected.requiredRides} (
                  {selected.ridesRemaining} remaining)
                </span>
                <span className="text-muted-foreground">Reward</span>
                <span>{formatCurrency(selected.rewardAmount)}</span>
                <span className="text-muted-foreground">Wallet credit</span>
                <span>{selected.willCreditWhen}</span>
                <span className="text-muted-foreground">Applied at</span>
                <span>{selected.createdAt ? formatDateTime(selected.createdAt) : "—"}</span>
                <span className="text-muted-foreground">Paid at</span>
                <span>{selected.paidAt ? formatDateTime(selected.paidAt) : "—"}</span>
              </div>
            </div>
          ) : null}
        </DialogContent>
      </Dialog>

      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit referral</DialogTitle>
            <DialogDescription>
              Change required rides or reward for this specific referral. Pending records re-check progress
              after save.
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-2">
            <div className="space-y-2">
              <Label>Required rides</Label>
              <Input
                type="number"
                min={1}
                value={editRides}
                onChange={(e) => setEditRides(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label>Reward amount (₹)</Label>
              <Input
                type="number"
                min={0}
                step="0.01"
                value={editAmount}
                onChange={(e) => setEditAmount(e.target.value)}
                disabled={selected?.status === "PAID"}
              />
              {selected?.status === "PAID" ? (
                <p className="text-xs text-muted-foreground">Amount cannot be changed after payout.</p>
              ) : null}
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditOpen(false)}>
              Cancel
            </Button>
            <Button onClick={() => void saveEdit()} disabled={actionLoading === selected?.id}>
              {actionLoading === selected?.id ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              ) : null}
              Save
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
