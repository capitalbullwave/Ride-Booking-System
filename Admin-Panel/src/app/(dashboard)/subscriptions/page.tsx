"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import Link from "next/link";
import {
  Crown,
  Eye,
  MoreHorizontal,
  Pencil,
  Plus,
  RefreshCw,
  Trash2,
  Users,
} from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { DataTable, Column } from "@/components/shared/data-table";
import { EmptyState } from "@/components/shared/empty-state";
import { SearchBar } from "@/components/shared/search-bar";
import { StatCard } from "@/components/shared/stat-card";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { Checkbox } from "@/components/ui/checkbox";
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
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { formatDate } from "@/lib/format";
import {
  createSubscriptionPlan,
  deleteSubscriptionPlan,
  fetchSubscriptionPlans,
  fetchSubscriptionSubscribers,
  updateSubscriptionPlan,
  type SubscriptionPlanBreakdown,
  type SubscriptionPlanItem,
  type SubscriptionPlanPayload,
  type SubscriptionSubscriber,
} from "@/lib/subscriptions-api";
import { toast } from "sonner";
import { useAutoRefresh } from "@/hooks/use-auto-refresh";

type PlanFormData = {
  slug: string;
  name: string;
  description: string;
  price: string;
  period_label: string;
  benefits: string;
  ride_discount_percent: string;
  is_popular: boolean;
  is_active: boolean;
  sort_order: string;
};

const emptyForm: PlanFormData = {
  slug: "",
  name: "",
  description: "",
  price: "0",
  period_label: "month",
  benefits: "",
  ride_discount_percent: "0",
  is_popular: false,
  is_active: true,
  sort_order: "0",
};

function planToForm(plan: SubscriptionPlanItem): PlanFormData {
  return {
    slug: plan.slug,
    name: plan.name,
    description: plan.description,
    price: String(plan.price),
    period_label: plan.period_label,
    benefits: plan.benefits.join("\n"),
    ride_discount_percent: String(plan.ride_discount_percent),
    is_popular: plan.is_popular,
    is_active: plan.is_active,
    sort_order: String(plan.sort_order),
  };
}

function formToPayload(form: PlanFormData, includeSlug: boolean): SubscriptionPlanPayload {
  const payload: SubscriptionPlanPayload = {
    name: form.name.trim(),
    description: form.description.trim(),
    price: Number(form.price) || 0,
    period_label: form.period_label.trim() || "month",
    benefits: form.benefits
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean),
    ride_discount_percent: Number(form.ride_discount_percent) || 0,
    is_popular: form.is_popular,
    is_active: form.is_active,
    sort_order: Number(form.sort_order) || 0,
  };
  if (includeSlug) {
    payload.slug = form.slug.trim().toLowerCase();
  }
  return payload;
}

function PlanFormFields({
  form,
  onChange,
  isEdit,
}: {
  form: PlanFormData;
  onChange: (updates: Partial<PlanFormData>) => void;
  isEdit?: boolean;
}) {
  return (
    <div className="grid gap-4 py-2">
      {!isEdit ? (
        <div className="space-y-2">
          <Label>Slug</Label>
          <Input
            placeholder="e.g. plus"
            value={form.slug}
            onChange={(e) => onChange({ slug: e.target.value.toLowerCase().replace(/\s+/g, "-") })}
          />
          <p className="text-xs text-muted-foreground">Unique ID used by the user app (lowercase).</p>
        </div>
      ) : null}
      <div className="space-y-2">
        <Label>Plan name</Label>
        <Input
          placeholder="Plus"
          value={form.name}
          onChange={(e) => onChange({ name: e.target.value })}
        />
      </div>
      <div className="space-y-2">
        <Label>Description</Label>
        <Textarea
          placeholder="Short description shown in the user app"
          value={form.description}
          onChange={(e) => onChange({ description: e.target.value })}
          rows={2}
        />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>Price (₹)</Label>
          <Input
            type="number"
            min="0"
            value={form.price}
            onChange={(e) => onChange({ price: e.target.value })}
          />
        </div>
        <div className="space-y-2">
          <Label>Period label</Label>
          <Input
            placeholder="month / forever"
            value={form.period_label}
            onChange={(e) => onChange({ period_label: e.target.value })}
          />
        </div>
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>Ride discount (%)</Label>
          <Input
            type="number"
            min="0"
            max="100"
            value={form.ride_discount_percent}
            onChange={(e) => onChange({ ride_discount_percent: e.target.value })}
          />
        </div>
        <div className="space-y-2">
          <Label>Sort order</Label>
          <Input
            type="number"
            value={form.sort_order}
            onChange={(e) => onChange({ sort_order: e.target.value })}
          />
        </div>
      </div>
      <div className="space-y-2">
        <Label>Benefits (one per line)</Label>
        <Textarea
          placeholder={"5% off on every ride\nPriority booking"}
          value={form.benefits}
          onChange={(e) => onChange({ benefits: e.target.value })}
          rows={4}
        />
      </div>
      <div className="flex flex-wrap gap-6">
        <label className="flex items-center gap-2 text-sm">
          <Checkbox checked={form.is_popular} onCheckedChange={(v) => onChange({ is_popular: !!v })} />
          Mark as popular
        </label>
        <label className="flex items-center gap-2 text-sm">
          <Checkbox checked={form.is_active} onCheckedChange={(v) => onChange({ is_active: !!v })} />
          Active (visible in user app)
        </label>
      </div>
    </div>
  );
}

export default function SubscriptionsPage() {
  const [plans, setPlans] = useState<SubscriptionPlanItem[]>([]);
  const [breakdown, setBreakdown] = useState<SubscriptionPlanBreakdown[]>([]);
  const [totalSubscribers, setTotalSubscribers] = useState(0);
  const [loading, setLoading] = useState(true);
  const [formOpen, setFormOpen] = useState(false);
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [editingPlan, setEditingPlan] = useState<SubscriptionPlanItem | null>(null);
  const [deletingPlan, setDeletingPlan] = useState<SubscriptionPlanItem | null>(null);
  const [form, setForm] = useState<PlanFormData>(emptyForm);
  const [saving, setSaving] = useState(false);
  const [subscribers, setSubscribers] = useState<SubscriptionSubscriber[]>([]);
  const [subscribersLoading, setSubscribersLoading] = useState(true);
  const [subscriberSearch, setSubscriberSearch] = useState("");
  const [subscriberPlanFilter, setSubscriberPlanFilter] = useState("all");
  const subscribersRef = useRef<HTMLDivElement>(null);

  const scrollToSubscribers = (planId?: string) => {
    if (planId) setSubscriberPlanFilter(planId);
    subscribersRef.current?.scrollIntoView({ behavior: "smooth", block: "start" });
  };

  const load = useCallback(async (options?: { silent?: boolean }) => {
    if (!options?.silent) {
      setLoading(true);
    }
    try {
      const data = await fetchSubscriptionPlans();
      setPlans(data.plans);
      setBreakdown(data.stats.plan_breakdown);
      setTotalSubscribers(data.stats.total_active_subscribers);
    } catch (error) {
      if (!options?.silent) {
        toast.error(error instanceof Error ? error.message : "Failed to load subscription plans");
      }
    } finally {
      if (!options?.silent) {
        setLoading(false);
      }
    }
  }, []);

  const loadSubscribers = useCallback(async (options?: { silent?: boolean }) => {
    if (!options?.silent) {
      setSubscribersLoading(true);
    }
    try {
      const data = await fetchSubscriptionSubscribers({
        plan_id: subscriberPlanFilter === "all" ? undefined : subscriberPlanFilter,
        search: subscriberSearch || undefined,
        page_size: 50,
      });
      setSubscribers(data.items);
    } catch (error) {
      if (!options?.silent) {
        toast.error(error instanceof Error ? error.message : "Failed to load subscribers");
      }
    } finally {
      if (!options?.silent) {
        setSubscribersLoading(false);
      }
    }
  }, [subscriberPlanFilter, subscriberSearch]);

  useEffect(() => {
    void load();
  }, [load]);

  useEffect(() => {
    void loadSubscribers();
  }, [loadSubscribers]);

  useAutoRefresh(() => {
    void load({ silent: true });
    void loadSubscribers({ silent: true });
  }, { intervalMs: 5000 });

  const openCreate = () => {
    setEditingPlan(null);
    setForm(emptyForm);
    setFormOpen(true);
  };

  const openEdit = (plan: SubscriptionPlanItem) => {
    setEditingPlan(plan);
    setForm(planToForm(plan));
    setFormOpen(true);
  };

  const handleSave = async () => {
    if (!form.name.trim()) {
      toast.error("Plan name is required");
      return;
    }
    if (!editingPlan && !form.slug.trim()) {
      toast.error("Slug is required");
      return;
    }

    setSaving(true);
    try {
      if (editingPlan) {
        await updateSubscriptionPlan(editingPlan.id, formToPayload(form, false));
        toast.success("Plan updated");
      } else {
        await createSubscriptionPlan(formToPayload(form, true));
        toast.success("Plan created");
      }
      setFormOpen(false);
      await load();
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Save failed");
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!deletingPlan) return;
    setSaving(true);
    try {
      await deleteSubscriptionPlan(deletingPlan.id);
      toast.success("Plan deleted");
      setDeleteOpen(false);
      setDeletingPlan(null);
      await load();
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Delete failed");
    } finally {
      setSaving(false);
    }
  };

  const subscriberColumns: Column<SubscriptionSubscriber>[] = [
    {
      key: "name",
      header: "User",
      cell: (row) => (
        <div>
          <Link href={`/users/${row.user_id}`} className="font-medium text-primary hover:underline">
            {row.name}
          </Link>
          <p className="text-xs text-muted-foreground">{row.phone}</p>
        </div>
      ),
    },
    { key: "email", header: "Email", cell: (row) => row.email },
    { key: "plan_name", header: "Plan", cell: (row) => row.plan_name },
    {
      key: "started_at",
      header: "Subscribed on",
      cell: (row) => (row.started_at ? formatDate(row.started_at) : "—"),
    },
    {
      key: "expires_at",
      header: "Expires",
      cell: (row) => (row.expires_at ? formatDate(row.expires_at) : "—"),
    },
    {
      key: "status",
      header: "Status",
      cell: (row) => <StatusBadge status={row.status} />,
    },
    {
      key: "view",
      header: "",
      cell: (row) => (
        <ButtonLink href={`/users/${row.user_id}`} size="sm" variant="outline">
          <Eye className="mr-1 h-3.5 w-3.5" />
          View user
        </ButtonLink>
      ),
    },
  ];

  const columns: Column<SubscriptionPlanItem>[] = [
    { key: "name", header: "Plan", cell: (row) => row.name, sortable: true },
    { key: "slug", header: "Slug", cell: (row) => row.slug },
    {
      key: "price",
      header: "Price",
      cell: (row) => `${row.price_label} ${row.period_label}`,
    },
    {
      key: "ride_discount_percent",
      header: "Ride discount",
      cell: (row) => `${row.ride_discount_percent}%`,
    },
    {
      key: "subscriber_count",
      header: "Subscribers",
      cell: (row) => (
        <button
          type="button"
          onClick={() => scrollToSubscribers(row.id)}
          className="font-semibold text-primary hover:underline"
        >
          {row.subscriber_count ?? 0}
        </button>
      ),
      sortable: true,
    },
    {
      key: "is_active",
      header: "Status",
      cell: (row) => <StatusBadge status={row.is_active ? "active" : "inactive"} />,
    },
    {
      key: "benefits",
      header: "Benefits",
      cell: (row) => row.benefits.slice(0, 2).join(" • ") || "—",
    },
    {
      key: "actions",
      header: "Actions",
      cell: (row) => (
        <DropdownMenu>
          <DropdownMenuTrigger render={<Button variant="ghost" size="icon" className="h-8 w-8" />}>
            <MoreHorizontal className="h-4 w-4" />
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-44">
            <DropdownMenuItem onClick={() => openEdit(row)}>
              <Pencil className="mr-2 h-4 w-4" />
              Edit
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => scrollToSubscribers(row.id)}>
              <Users className="mr-2 h-4 w-4" />
              View subscribers
            </DropdownMenuItem>
            <DropdownMenuItem
              onClick={async () => {
                try {
                  await updateSubscriptionPlan(row.id, { is_active: !row.is_active });
                  toast.success(row.is_active ? "Plan deactivated" : "Plan activated");
                  await load();
                } catch (error) {
                  toast.error(error instanceof Error ? error.message : "Update failed");
                }
              }}
            >
              {row.is_active ? "Deactivate" : "Activate"}
            </DropdownMenuItem>
            {row.slug !== "free" ? (
              <>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  variant="destructive"
                  onClick={() => {
                    setDeletingPlan(row);
                    setDeleteOpen(true);
                  }}
                >
                  <Trash2 className="mr-2 h-4 w-4" />
                  Delete
                </DropdownMenuItem>
              </>
            ) : null}
          </DropdownMenuContent>
        </DropdownMenu>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Subscriptions"
        description="Create, edit and delete membership plans. User app fetches plans live from here."
      >
        <Button variant="outline" onClick={() => void load()}>
          <RefreshCw className="mr-2 h-4 w-4" />
          Refresh
        </Button>
        <Button onClick={openCreate}>
          <Plus className="mr-2 h-4 w-4" />
          Create plan
        </Button>
      </PageHeader>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <button type="button" onClick={() => scrollToSubscribers()} className="text-left">
          <StatCard title="Total subscribers" value={totalSubscribers} icon={Users} />
        </button>
        {breakdown.map((item) => (
          <button
            key={item.plan_id}
            type="button"
            onClick={() => scrollToSubscribers(item.plan_id)}
            className="text-left"
          >
            <StatCard
              title={item.plan_name}
              value={item.subscriber_count}
              change="active subscribers"
              icon={Crown}
              iconColor="bg-secondary/20 text-secondary"
            />
          </button>
        ))}
      </div>

      <div>
        <h2 className="font-heading text-lg font-semibold">All plans</h2>
        <p className="text-sm text-muted-foreground">
          Create custom plans or edit existing ones. Only active plans show in the user app.
        </p>
      </div>

      {!loading && plans.length === 0 ? (
        <EmptyState
          icon={Crown}
          title="No subscription plans yet"
          description="Create your first plan — users will see it instantly in Profile → Subscriptions."
          actionLabel="Create plan"
          onAction={openCreate}
        />
      ) : (
        <DataTable
          columns={columns}
          data={plans}
          emptyTitle={loading ? "Loading subscription plans..." : "No subscription plans found."}
          emptyDescription={
            loading
              ? "Fetching plans from the server."
              : "Use Create plan above to add a new membership tier."
          }
        />
      )}

      <div ref={subscribersRef} className="space-y-4 border-t pt-8">
        <div>
          <h2 className="font-heading text-lg font-semibold">Subscriber details</h2>
          <p className="text-sm text-muted-foreground">
            Users who selected a plan in the app. Click a subscriber count above to filter by plan.
          </p>
        </div>

        <div className="flex flex-col gap-3 sm:flex-row">
          <SearchBar
            value={subscriberSearch}
            onChange={setSubscriberSearch}
            placeholder="Search name, phone, email..."
            className="flex-1"
          />
          <Select value={subscriberPlanFilter} onValueChange={setSubscriberPlanFilter}>
            <SelectTrigger className="w-full sm:w-[200px]">
              <SelectValue placeholder="Filter by plan" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All plans</SelectItem>
              {plans.map((plan) => (
                <SelectItem key={plan.id} value={plan.id}>
                  {plan.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <DataTable
          columns={subscriberColumns}
          data={subscribers}
          emptyTitle={subscribersLoading ? "Loading subscribers..." : "No subscribers found"}
          emptyDescription={
            subscribersLoading
              ? "Fetching subscriber list from the server."
              : "Users appear here after they subscribe to a plan in the app."
          }
        />
      </div>

      <Dialog open={formOpen} onOpenChange={setFormOpen}>
        <DialogContent className="max-h-[90vh] overflow-y-auto sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>{editingPlan ? "Edit subscription plan" : "Create subscription plan"}</DialogTitle>
            <DialogDescription>
              Fill in the details below. Users will see this plan in the app after you save (if active).
            </DialogDescription>
          </DialogHeader>
          <PlanFormFields
            form={form}
            onChange={(updates) => setForm((prev) => ({ ...prev, ...updates }))}
            isEdit={!!editingPlan}
          />
          <DialogFooter>
            <Button variant="outline" onClick={() => setFormOpen(false)}>
              Cancel
            </Button>
            <Button onClick={() => void handleSave()} disabled={saving}>
              {saving ? "Saving…" : editingPlan ? "Save changes" : "Create plan"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete plan</DialogTitle>
            <DialogDescription>
              Delete &quot;{deletingPlan?.name}&quot;? This only works when no users are subscribed.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteOpen(false)}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={() => void handleDelete()} disabled={saving}>
              Delete plan
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
