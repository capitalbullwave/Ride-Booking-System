"use client";

import { useCallback, useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
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
import { formatCurrency } from "@/lib/format";
import {
  addCorporateEmployee,
  listCorporateCompanies,
  listCorporateEmployees,
  removeCorporateEmployee,
  setEmployeeStatus,
  type CorporateCompany,
  type CorporateEmployee,
} from "@/lib/corporate-api";
import { toast } from "sonner";

export default function CorporateEmployeesPage() {
  const searchParams = useSearchParams();
  const [companies, setCompanies] = useState<CorporateCompany[]>([]);
  const [companyId, setCompanyId] = useState(searchParams.get("company_id") || "");
  const [items, setItems] = useState<CorporateEmployee[]>([]);
  const [search, setSearch] = useState("");
  const [addOpen, setAddOpen] = useState(false);
  const [phone, setPhone] = useState("");
  const [employeeCode, setEmployeeCode] = useState("");
  const [department, setDepartment] = useState("");
  const [designation, setDesignation] = useState("");

  const loadCompanies = useCallback(async () => {
    const data = await listCorporateCompanies({ status: "APPROVED", limit: 100 });
    setCompanies(data.items);
    if (!companyId && data.items[0]) setCompanyId(data.items[0].id);
  }, [companyId]);

  const load = useCallback(async () => {
    if (!companyId) return;
    try {
      const data = await listCorporateEmployees(companyId, {
        search: search || undefined,
      });
      setItems(data.items);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to load employees");
    }
  }, [companyId, search]);

  useEffect(() => {
    void loadCompanies().catch(() => toast.error("Failed to load companies"));
  }, [loadCompanies]);

  useEffect(() => {
    void load();
  }, [load]);

  const columns: Column<CorporateEmployee>[] = [
    {
      key: "name",
      header: "Employee Name",
      cell: (row) => row.employee_name || "—",
    },
    { key: "employee_code", header: "Employee Code", cell: (row) => row.employee_code },
    { key: "department", header: "Department", cell: (row) => row.department || "—" },
    { key: "designation", header: "Designation", cell: (row) => row.designation || "—" },
    { key: "phone", header: "Phone", cell: (row) => row.phone || "—" },
    { key: "email", header: "Email", cell: (row) => row.email || "—" },
    { key: "ride_count", header: "Ride Count", cell: (row) => row.ride_count ?? 0 },
    {
      key: "monthly_spend",
      header: "Monthly Spend",
      cell: (row) => formatCurrency(row.monthly_spend ?? 0),
    },
    {
      key: "status",
      header: "Status",
      cell: (row) => <StatusBadge status={row.status.toLowerCase()} />,
    },
    {
      key: "actions",
      header: "Actions",
      cell: (row) => (
        <div className="flex gap-2">
          {row.status !== "ACTIVE" ? (
            <Button
              size="sm"
              variant="outline"
              onClick={async () => {
                await setEmployeeStatus(companyId, row.id, "activate");
                toast.success("Activated");
                void load();
              }}
            >
              Activate
            </Button>
          ) : (
            <Button
              size="sm"
              variant="outline"
              onClick={async () => {
                await setEmployeeStatus(companyId, row.id, "deactivate");
                toast.success("Deactivated");
                void load();
              }}
            >
              Deactivate
            </Button>
          )}
          <Button
            size="sm"
            variant="destructive"
            onClick={async () => {
              await removeCorporateEmployee(companyId, row.id);
              toast.success("Removed");
              void load();
            }}
          >
            Remove
          </Button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Employees"
        description="Link user accounts to approved companies."
      >
        <Button onClick={() => setAddOpen(true)} disabled={!companyId}>
          Add Employee
        </Button>
      </PageHeader>

      <div className="flex flex-col gap-3 sm:flex-row">
        <Select value={companyId} onValueChange={(v) => setCompanyId(v ?? "")}>
          <SelectTrigger className="w-[280px]">
            <SelectValue placeholder="Select company" />
          </SelectTrigger>
          <SelectContent>
            {companies.map((c) => (
              <SelectItem key={c.id} value={c.id}>
                {c.company_name}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <SearchBar
          value={search}
          onChange={setSearch}
          placeholder="Search employee…"
          className="flex-1"
        />
      </div>

      <DataTable columns={columns} data={items} emptyTitle="No employees" />

      <Dialog open={addOpen} onOpenChange={setAddOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Add Employee</DialogTitle>
          </DialogHeader>
          <div className="grid gap-3">
            <div className="space-y-2">
              <Label>User phone</Label>
              <Input value={phone} onChange={(e) => setPhone(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Employee code</Label>
              <Input value={employeeCode} onChange={(e) => setEmployeeCode(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Department</Label>
              <Input value={department} onChange={(e) => setDepartment(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Designation</Label>
              <Input value={designation} onChange={(e) => setDesignation(e.target.value)} />
            </div>
          </div>
          <DialogFooter>
            <Button
              onClick={async () => {
                try {
                  await addCorporateEmployee(companyId, {
                    phone,
                    employee_code: employeeCode,
                    department: department || undefined,
                    designation: designation || undefined,
                  });
                  toast.success("Employee added");
                  setAddOpen(false);
                  setPhone("");
                  setEmployeeCode("");
                  void load();
                } catch (e) {
                  toast.error(e instanceof Error ? e.message : "Failed to add");
                }
              }}
            >
              Save
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
