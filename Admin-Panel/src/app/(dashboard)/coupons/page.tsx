"use client";

import { useMemo, useState } from "react";
import {
  Plus,
  MoreHorizontal,
  Pencil,
  Ban,
  CheckCircle,
  Copy,
  Trash2,
  Eye,
} from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
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
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
  DialogDescription,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { coupons as initialCoupons } from "@/data/mock-data";
import { Coupon, CouponStatus, DiscountType } from "@/types";
import { formatDate, capitalize } from "@/lib/format";
import { toast } from "sonner";

type CouponFormData = {
  code: string;
  discountType: DiscountType;
  discountValue: string;
  maxDiscount: string;
  expiryDate: string;
  usageLimit: string;
};

const emptyForm: CouponFormData = {
  code: "",
  discountType: "percentage",
  discountValue: "",
  maxDiscount: "",
  expiryDate: "",
  usageLimit: "",
};

function couponToForm(coupon: Coupon): CouponFormData {
  return {
    code: coupon.code,
    discountType: coupon.discountType,
    discountValue: String(coupon.discountValue),
    maxDiscount: String(coupon.maxDiscount),
    expiryDate: coupon.expiryDate,
    usageLimit: String(coupon.usageLimit),
  };
}

function CouponFormFields({
  form,
  onChange,
}: {
  form: CouponFormData;
  onChange: (updates: Partial<CouponFormData>) => void;
}) {
  return (
    <div className="grid gap-4 py-2">
      <div className="space-y-2">
        <Label>Coupon Code</Label>
        <Input
          placeholder="e.g. WAVE50"
          value={form.code}
          onChange={(e) => onChange({ code: e.target.value.toUpperCase() })}
        />
      </div>
      <div className="space-y-2">
        <Label>Discount Type</Label>
        <Select
          value={form.discountType}
          onValueChange={(v) => v && onChange({ discountType: v as DiscountType })}
        >
          <SelectTrigger><SelectValue /></SelectTrigger>
          <SelectContent>
            <SelectItem value="percentage">Percentage</SelectItem>
            <SelectItem value="flat">Flat Amount</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>Discount Value</Label>
          <Input
            type="number"
            placeholder="50"
            value={form.discountValue}
            onChange={(e) => onChange({ discountValue: e.target.value })}
          />
        </div>
        <div className="space-y-2">
          <Label>Max Discount (₹)</Label>
          <Input
            type="number"
            placeholder="100"
            value={form.maxDiscount}
            onChange={(e) => onChange({ maxDiscount: e.target.value })}
          />
        </div>
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>Expiry Date</Label>
          <Input
            type="date"
            value={form.expiryDate}
            onChange={(e) => onChange({ expiryDate: e.target.value })}
          />
        </div>
        <div className="space-y-2">
          <Label>Usage Limit</Label>
          <Input
            type="number"
            placeholder="1000"
            value={form.usageLimit}
            onChange={(e) => onChange({ usageLimit: e.target.value })}
          />
        </div>
      </div>
    </div>
  );
}

export default function CouponsPage() {
  const [tab, setTab] = useState("active");
  const [couponList, setCouponList] = useState<Coupon[]>(initialCoupons);
  const [createOpen, setCreateOpen] = useState(false);
  const [editOpen, setEditOpen] = useState(false);
  const [viewOpen, setViewOpen] = useState(false);
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [selectedCoupon, setSelectedCoupon] = useState<Coupon | null>(null);
  const [createForm, setCreateForm] = useState<CouponFormData>(emptyForm);
  const [editForm, setEditForm] = useState<CouponFormData>(emptyForm);

  const filteredCoupons = useMemo(() => {
    return couponList.filter((c) => {
      if (tab === "active") return c.status === "active";
      if (tab === "expired") return c.status === "expired";
      return c.status === "disabled";
    });
  }, [couponList, tab]);

  const updateCouponStatus = (id: string, status: CouponStatus) => {
    setCouponList((prev) =>
      prev.map((c) => (c.id === id ? { ...c, status } : c))
    );
  };

  const handleCreate = () => {
    if (!createForm.code.trim()) {
      toast.error("Coupon code is required");
      return;
    }
    const newCoupon: Coupon = {
      id: `CPN-${Date.now()}`,
      code: createForm.code,
      discountType: createForm.discountType,
      discountValue: Number(createForm.discountValue) || 0,
      maxDiscount: Number(createForm.maxDiscount) || 0,
      expiryDate: createForm.expiryDate || new Date().toISOString().split("T")[0],
      usageLimit: Number(createForm.usageLimit) || 100,
      usedCount: 0,
      status: "active",
      createdAt: new Date().toISOString().split("T")[0],
    };
    setCouponList((prev) => [newCoupon, ...prev]);
    setCreateForm(emptyForm);
    setCreateOpen(false);
    toast.success(`Coupon ${newCoupon.code} created`);
  };

  const handleEdit = () => {
    if (!selectedCoupon || !editForm.code.trim()) return;
    setCouponList((prev) =>
      prev.map((c) =>
        c.id === selectedCoupon.id
          ? {
              ...c,
              code: editForm.code,
              discountType: editForm.discountType,
              discountValue: Number(editForm.discountValue) || 0,
              maxDiscount: Number(editForm.maxDiscount) || 0,
              expiryDate: editForm.expiryDate,
              usageLimit: Number(editForm.usageLimit) || 0,
            }
          : c
      )
    );
    setEditOpen(false);
    setSelectedCoupon(null);
    toast.success("Coupon updated successfully");
  };

  const handleDuplicate = (coupon: Coupon) => {
    const duplicate: Coupon = {
      ...coupon,
      id: `CPN-${Date.now()}`,
      code: `${coupon.code}_COPY`,
      usedCount: 0,
      status: "active",
      createdAt: new Date().toISOString().split("T")[0],
    };
    setCouponList((prev) => [duplicate, ...prev]);
    toast.success(`Duplicated as ${duplicate.code}`);
  };

  const handleDelete = () => {
    if (!selectedCoupon) return;
    setCouponList((prev) => prev.filter((c) => c.id !== selectedCoupon.id));
    setDeleteOpen(false);
    toast.success(`Coupon ${selectedCoupon.code} deleted`);
    setSelectedCoupon(null);
  };

  const openEdit = (coupon: Coupon) => {
    setSelectedCoupon(coupon);
    setEditForm(couponToForm(coupon));
    setEditOpen(true);
  };

  const openView = (coupon: Coupon) => {
    setSelectedCoupon(coupon);
    setViewOpen(true);
  };

  const openDelete = (coupon: Coupon) => {
    setSelectedCoupon(coupon);
    setDeleteOpen(true);
  };

  const columns: Column<Coupon>[] = [
    { key: "code", header: "Code", cell: (c) => <span className="font-mono font-bold">{c.code}</span> },
    { key: "discountType", header: "Type", cell: (c) => capitalize(c.discountType) },
    {
      key: "discountValue",
      header: "Value",
      cell: (c) => (c.discountType === "percentage" ? `${c.discountValue}%` : `₹${c.discountValue}`),
    },
    { key: "maxDiscount", header: "Max Discount", cell: (c) => `₹${c.maxDiscount}` },
    { key: "expiryDate", header: "Expiry", cell: (c) => formatDate(c.expiryDate) },
    { key: "usage", header: "Usage", cell: (c) => `${c.usedCount}/${c.usageLimit}` },
    { key: "status", header: "Status", cell: (c) => <StatusBadge status={c.status} /> },
    {
      key: "actions",
      header: "Actions",
      cell: (coupon) => (
        <DropdownMenu>
          <DropdownMenuTrigger render={<Button variant="ghost" size="icon" className="h-8 w-8" />}>
            <MoreHorizontal className="h-4 w-4" />
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-48">
            <DropdownMenuItem onClick={() => openView(coupon)}>
              <Eye className="mr-2 h-4 w-4" /> View Details
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => openEdit(coupon)}>
              <Pencil className="mr-2 h-4 w-4" /> Edit Coupon
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => handleDuplicate(coupon)}>
              <Copy className="mr-2 h-4 w-4" /> Duplicate
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            {coupon.status === "active" ? (
              <DropdownMenuItem onClick={() => { updateCouponStatus(coupon.id, "disabled"); toast.success(`${coupon.code} deactivated`); }}>
                <Ban className="mr-2 h-4 w-4" /> Deactivate
              </DropdownMenuItem>
            ) : coupon.status === "disabled" ? (
              <DropdownMenuItem onClick={() => { updateCouponStatus(coupon.id, "active"); toast.success(`${coupon.code} activated`); }}>
                <CheckCircle className="mr-2 h-4 w-4" /> Activate
              </DropdownMenuItem>
            ) : null}
            <DropdownMenuItem className="text-destructive" onClick={() => openDelete(coupon)}>
              <Trash2 className="mr-2 h-4 w-4" /> Delete
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader title="Coupon Management" description="Create and manage promotional coupons">
        <ExportButton filename="coupons" />
        <Dialog open={createOpen} onOpenChange={setCreateOpen}>
          <DialogTrigger render={<Button />}>
            <Plus className="mr-2 h-4 w-4" /> Create Coupon
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Create New Coupon</DialogTitle>
            </DialogHeader>
            <CouponFormFields form={createForm} onChange={(u) => setCreateForm((f) => ({ ...f, ...u }))} />
            <DialogFooter>
              <Button variant="outline" onClick={() => setCreateOpen(false)}>Cancel</Button>
              <Button onClick={handleCreate}>Create Coupon</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </PageHeader>

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="active">Active</TabsTrigger>
          <TabsTrigger value="expired">Expired</TabsTrigger>
          <TabsTrigger value="disabled">Disabled</TabsTrigger>
        </TabsList>
        <TabsContent value={tab} className="mt-6">
          <DataTable
            data={filteredCoupons}
            columns={columns}
            emptyTitle="No coupons found"
            emptyDescription="Create a new coupon to get started."
          />
        </TabsContent>
      </Tabs>

      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Coupon</DialogTitle>
            <DialogDescription>Update coupon details for {selectedCoupon?.code}</DialogDescription>
          </DialogHeader>
          <CouponFormFields form={editForm} onChange={(u) => setEditForm((f) => ({ ...f, ...u }))} />
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditOpen(false)}>Cancel</Button>
            <Button onClick={handleEdit}>Save Changes</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={viewOpen} onOpenChange={setViewOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle className="font-mono">{selectedCoupon?.code}</DialogTitle>
            <DialogDescription>Coupon details and usage stats</DialogDescription>
          </DialogHeader>
          {selectedCoupon && (
            <div className="grid gap-3 sm:grid-cols-2">
              {[
                ["Type", capitalize(selectedCoupon.discountType)],
                ["Value", selectedCoupon.discountType === "percentage" ? `${selectedCoupon.discountValue}%` : `₹${selectedCoupon.discountValue}`],
                ["Max Discount", `₹${selectedCoupon.maxDiscount}`],
                ["Expiry", formatDate(selectedCoupon.expiryDate)],
                ["Usage", `${selectedCoupon.usedCount} / ${selectedCoupon.usageLimit}`],
                ["Created", formatDate(selectedCoupon.createdAt)],
                ["Status", capitalize(selectedCoupon.status)],
              ].map(([label, value]) => (
                <div key={label} className="rounded-[1rem] border border-border/80 bg-muted/30 p-3">
                  <p className="text-xs text-muted-foreground">{label}</p>
                  <p className="mt-1 font-medium">{value}</p>
                </div>
              ))}
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setViewOpen(false)}>Close</Button>
            <Button onClick={() => { setViewOpen(false); if (selectedCoupon) openEdit(selectedCoupon); }}>
              <Pencil className="mr-2 h-4 w-4" /> Edit
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete Coupon</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete <span className="font-mono font-semibold">{selectedCoupon?.code}</span>? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteOpen(false)}>Cancel</Button>
            <Button variant="destructive" onClick={handleDelete}>Delete Coupon</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
