"use client";

import { useCallback, useEffect, useState } from "react";
import {
  Eye,
  CheckCircle,
  XCircle,
  Ban,
  Trash2,
  MoreHorizontal,
  Pencil,
  Plus,
} from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { SearchBar } from "@/components/shared/search-bar";
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
import { formatCurrency, formatDate } from "@/lib/format";
import {
  approveCorporateCompany,
  deleteCorporateCompany,
  listCorporateCompanies,
  registerCorporateCompany,
  rejectCorporateCompany,
  suspendCorporateCompany,
  type CorporateCompany,
} from "@/lib/corporate-api";
import { toast } from "sonner";

const emptyCreate = {
  company_name: "",
  gst_number: "",
  pan_number: "",
  website: "",
  industry: "",
  company_size: "",
  address: "",
  city: "",
  state: "",
  country: "India",
  contact_person: "",
  email: "",
  phone: "",
  password: "",
};

export default function CorporateCompaniesPage() {
  const [items, setItems] = useState<CorporateCompany[]>([]);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("all");
  const [createOpen, setCreateOpen] = useState(false);
  const [creating, setCreating] = useState(false);
  const [form, setForm] = useState(emptyCreate);

  const load = useCallback(async () => {
    try {
      const data = await listCorporateCompanies({
        status: status === "all" ? undefined : status,
        search: search || undefined,
      });
      setItems(data.items);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to load companies");
    }
  }, [search, status]);

  useEffect(() => {
    void load();
  }, [load]);

  const columns: Column<CorporateCompany>[] = [
    {
      key: "company_name",
      header: "Company Name",
      cell: (row) => (
        <div>
          <p className="font-medium">{row.company_name}</p>
          <p className="text-xs text-muted-foreground">{row.company_code}</p>
        </div>
      ),
    },
    { key: "contact_person", header: "Contact Person", cell: (row) => row.contact_person },
    { key: "email", header: "Email", cell: (row) => row.email },
    { key: "phone", header: "Phone", cell: (row) => row.phone },
    {
      key: "status",
      header: "Status",
      cell: (row) => <StatusBadge status={row.status.toLowerCase()} />,
    },
    {
      key: "employees",
      header: "Employees",
      cell: (row) => row.employee_count ?? 0,
    },
    {
      key: "today_rides",
      header: "Today's Rides",
      cell: (row) => row.today_rides ?? 0,
    },
    {
      key: "monthly_spend",
      header: "Monthly Spend",
      cell: (row) => formatCurrency(row.monthly_spend ?? 0),
    },
    {
      key: "created_at",
      header: "Created Date",
      cell: (row) => formatDate(row.created_at),
    },
    {
      key: "actions",
      header: "Actions",
      cell: (row) => (
        <DropdownMenu>
          <DropdownMenuTrigger render={<Button size="icon" variant="ghost" />}>
            <MoreHorizontal className="h-4 w-4" />
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem
              onClick={() => {
                window.location.href = `/corporate/companies/${row.id}`;
              }}
            >
              <Eye className="mr-2 h-4 w-4" />
              View
            </DropdownMenuItem>
            <DropdownMenuItem
              onClick={() => {
                window.location.href = `/corporate/companies/${row.id}?edit=1`;
              }}
            >
              <Pencil className="mr-2 h-4 w-4" />
              Edit
            </DropdownMenuItem>
            {row.status === "PENDING" && (
              <>
                <DropdownMenuItem
                  onClick={async () => {
                    try {
                      await approveCorporateCompany(row.id);
                      toast.success("Company approved");
                      void load();
                    } catch (e) {
                      toast.error(e instanceof Error ? e.message : "Approve failed");
                    }
                  }}
                >
                  <CheckCircle className="mr-2 h-4 w-4" />
                  Approve
                </DropdownMenuItem>
                <DropdownMenuItem
                  onClick={async () => {
                    try {
                      await rejectCorporateCompany(row.id, "Rejected by admin");
                      toast.success("Company rejected");
                      void load();
                    } catch (e) {
                      toast.error(e instanceof Error ? e.message : "Reject failed");
                    }
                  }}
                >
                  <XCircle className="mr-2 h-4 w-4" />
                  Reject
                </DropdownMenuItem>
              </>
            )}
            {row.status === "APPROVED" && (
              <DropdownMenuItem
                onClick={async () => {
                  try {
                    await suspendCorporateCompany(row.id);
                    toast.success("Company suspended");
                    void load();
                  } catch (e) {
                    toast.error(e instanceof Error ? e.message : "Suspend failed");
                  }
                }}
              >
                <Ban className="mr-2 h-4 w-4" />
                Suspend
              </DropdownMenuItem>
            )}
            <DropdownMenuSeparator />
            <DropdownMenuItem
              className="text-destructive"
              onClick={async () => {
                if (!confirm(`Delete ${row.company_name}?`)) return;
                try {
                  await deleteCorporateCompany(row.id);
                  toast.success("Company deleted");
                  void load();
                } catch (e) {
                  toast.error(e instanceof Error ? e.message : "Delete failed");
                }
              }}
            >
              <Trash2 className="mr-2 h-4 w-4" />
              Delete
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Companies"
        description="Register, approve, and manage corporate accounts."
      >
        <Button onClick={() => setCreateOpen(true)}>
          <Plus className="mr-1 h-4 w-4" />
          Create Company
        </Button>
      </PageHeader>
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
        <SearchBar
          value={search}
          onChange={setSearch}
          placeholder="Search company, code, email…"
          className="flex-1"
        />
        <Select value={status} onValueChange={(v) => setStatus(v ?? "all")}>
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All statuses</SelectItem>
            <SelectItem value="PENDING">Pending</SelectItem>
            <SelectItem value="APPROVED">Approved</SelectItem>
            <SelectItem value="REJECTED">Rejected</SelectItem>
            <SelectItem value="SUSPENDED">Suspended</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <DataTable columns={columns} data={items} />

      <Dialog open={createOpen} onOpenChange={setCreateOpen}>
        <DialogContent className="max-h-[90vh] overflow-y-auto sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>Create Company</DialogTitle>
          </DialogHeader>
          <div className="grid gap-3">
            {(
              [
                ["company_name", "Company name *"],
                ["contact_person", "Contact person *"],
                ["email", "Email *"],
                ["phone", "Phone *"],
                ["password", "Password *"],
                ["gst_number", "GST number"],
                ["pan_number", "PAN number"],
                ["website", "Website"],
                ["industry", "Industry"],
                ["company_size", "Company size"],
                ["address", "Address"],
                ["city", "City"],
                ["state", "State"],
                ["country", "Country"],
              ] as const
            ).map(([key, label]) => (
              <div key={key} className="space-y-1.5">
                <Label>{label}</Label>
                <Input
                  type={
                    key === "password" ? "password" : key === "email" ? "email" : "text"
                  }
                  value={form[key]}
                  onChange={(e) => setForm((f) => ({ ...f, [key]: e.target.value }))}
                />
              </div>
            ))}
          </div>
          <DialogFooter>
            <Button
              disabled={creating}
              onClick={async () => {
                if (
                  !form.company_name.trim() ||
                  !form.contact_person.trim() ||
                  !form.email.trim() ||
                  !form.phone.trim() ||
                  form.password.length < 8
                ) {
                  toast.error("Fill required fields. Password min 8 characters.");
                  return;
                }
                setCreating(true);
                try {
                  const created = await registerCorporateCompany({
                    company_name: form.company_name.trim(),
                    contact_person: form.contact_person.trim(),
                    email: form.email.trim(),
                    phone: form.phone.trim(),
                    password: form.password,
                    gst_number: form.gst_number.trim() || undefined,
                    pan_number: form.pan_number.trim() || undefined,
                    website: form.website.trim() || undefined,
                    industry: form.industry.trim() || undefined,
                    company_size: form.company_size.trim() || undefined,
                    address: form.address.trim() || undefined,
                    city: form.city.trim() || undefined,
                    state: form.state.trim() || undefined,
                    country: form.country.trim() || "India",
                  });
                  toast.success(
                    `Created ${created.company.company_name} (${created.company.status})`,
                  );
                  setCreateOpen(false);
                  setForm(emptyCreate);
                  void load();
                } catch (e) {
                  toast.error(e instanceof Error ? e.message : "Create failed");
                } finally {
                  setCreating(false);
                }
              }}
            >
              {creating ? "Creating…" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
