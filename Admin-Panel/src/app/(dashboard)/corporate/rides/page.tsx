"use client";

import { useCallback, useEffect, useState } from "react";
import { Eye } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { DataTable, Column } from "@/components/shared/data-table";
import { StatusBadge } from "@/components/shared/status-badge";
import { ButtonLink } from "@/components/ui/button-link";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { formatCurrency, formatDateTime } from "@/lib/format";
import {
  listCorporateCompanies,
  listCorporateRides,
  type CorporateCompany,
  type CorporateRide,
} from "@/lib/corporate-api";
import { toast } from "sonner";

export default function CorporateRidesPage() {
  const [companies, setCompanies] = useState<CorporateCompany[]>([]);
  const [companyId, setCompanyId] = useState("all");
  const [status, setStatus] = useState("all");
  const [items, setItems] = useState<CorporateRide[]>([]);

  const load = useCallback(async () => {
    try {
      const data = await listCorporateRides({
        company_id: companyId === "all" ? undefined : companyId,
        status: status === "all" ? undefined : status,
      });
      setItems(data.items);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to load rides");
    }
  }, [companyId, status]);

  useEffect(() => {
    void listCorporateCompanies({ limit: 100 })
      .then((d) => setCompanies(d.items))
      .catch(() => undefined);
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const columns: Column<CorporateRide>[] = [
    {
      key: "public_id",
      header: "Ride",
      cell: (r) => (
        <ButtonLink
          href={`/rides/${r.id}?from=corporate`}
          variant="link"
          className="h-auto p-0 font-mono text-xs font-medium"
        >
          {r.public_id}
        </ButtonLink>
      ),
    },
    { key: "company_name", header: "Company", cell: (r) => r.company_name || "—" },
    { key: "employee_name", header: "Employee", cell: (r) => r.employee_name || "—" },
    {
      key: "status",
      header: "Status",
      cell: (r) => <StatusBadge status={r.status.toLowerCase()} />,
    },
    {
      key: "fare",
      header: "Fare",
      cell: (r) => formatCurrency(r.final_fare ?? r.estimated_fare),
    },
    { key: "payment_source", header: "Paid By", cell: (r) => r.payment_source },
    {
      key: "route",
      header: "Route",
      cell: (r) => (
        <div className="max-w-xs truncate text-xs">
          {r.pickup_address} → {r.dropoff_address}
        </div>
      ),
    },
    {
      key: "created_at",
      header: "Created",
      cell: (r) => formatDateTime(r.created_at),
    },
    {
      key: "actions",
      header: "Actions",
      cell: (r) => (
        <ButtonLink
          variant="ghost"
          size="icon"
          className="h-8 w-8"
          href={`/rides/${r.id}?from=corporate`}
          title="View ride details"
        >
          <Eye className="h-4 w-4" />
        </ButtonLink>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Corporate Rides"
        description="All rides billed to companies."
      />
      <div className="flex flex-wrap gap-3">
        <Select value={companyId} onValueChange={(v) => setCompanyId(v ?? "all")}>
          <SelectTrigger className="w-[240px]">
            <SelectValue placeholder="Company" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All companies</SelectItem>
            {companies.map((c) => (
              <SelectItem key={c.id} value={c.id}>
                {c.company_name}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select value={status} onValueChange={(v) => setStatus(v ?? "all")}>
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All statuses</SelectItem>
            <SelectItem value="COMPLETED">Completed</SelectItem>
            <SelectItem value="CANCELLED">Cancelled</SelectItem>
            <SelectItem value="REQUESTED">Requested</SelectItem>
            <SelectItem value="ACCEPTED">Accepted</SelectItem>
            <SelectItem value="STARTED">Started</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <DataTable columns={columns} data={items} emptyTitle="No corporate rides" />
    </div>
  );
}
