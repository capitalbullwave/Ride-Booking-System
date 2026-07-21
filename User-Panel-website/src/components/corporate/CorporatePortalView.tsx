"use client";

import { FormEvent, useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Building2, Loader2, LogOut, Plus, UserPlus } from "lucide-react";
import { LandingHeader } from "@/components/landing/LandingHeader";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ROUTES } from "@/constants/routes";
import {
  addMyEmployee,
  fetchCompanyProfile,
  listMyEmployees,
  removeMyEmployee,
  setMyEmployeeStatus,
  type CompanyEmployee,
  type CompanyProfile,
} from "@/lib/corporate-api";
import { clearCompanySession, getCompanySession } from "@/lib/company-session";

export function CorporatePortalView() {
  const router = useRouter();
  const [profile, setProfile] = useState<CompanyProfile | null>(null);
  const [employees, setEmployees] = useState<CompanyEmployee[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [phone, setPhone] = useState("");
  const [employeeCode, setEmployeeCode] = useState("");
  const [department, setDepartment] = useState("");
  const [designation, setDesignation] = useState("");
  const [adding, setAdding] = useState(false);
  const [addError, setAddError] = useState("");

  const load = useCallback(async () => {
    if (!getCompanySession()?.accessToken) {
      router.replace(ROUTES.corporateLogin);
      return;
    }
    setLoading(true);
    setError("");
    try {
      const [me, list] = await Promise.all([
        fetchCompanyProfile(),
        listMyEmployees(),
      ]);
      setProfile(me);
      setEmployees(list.items);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load portal");
      if (String(err).toLowerCase().includes("login")) {
        router.replace(ROUTES.corporateLogin);
      }
    } finally {
      setLoading(false);
    }
  }, [router]);

  useEffect(() => {
    void load();
  }, [load]);

  const onAdd = async (e: FormEvent) => {
    e.preventDefault();
    setAddError("");
    setAdding(true);
    try {
      await addMyEmployee({
        phone: phone.trim(),
        employee_code: employeeCode.trim(),
        department: department.trim() || undefined,
        designation: designation.trim() || undefined,
      });
      setPhone("");
      setEmployeeCode("");
      setDepartment("");
      setDesignation("");
      await load();
    } catch (err) {
      setAddError(err instanceof Error ? err.message : "Failed to add employee");
    } finally {
      setAdding(false);
    }
  };

  const logout = () => {
    clearCompanySession();
    router.replace(ROUTES.corporateLogin);
  };

  return (
    <div className="min-h-[100dvh] bg-background">
      <LandingHeader />
      <main className="mx-auto max-w-4xl px-6 py-10">
        <div className="mb-8 flex flex-wrap items-start justify-between gap-4">
          <div className="flex items-start gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/10 text-primary">
              <Building2 className="h-5 w-5" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-foreground">Company portal</h1>
              <p className="text-sm text-muted-foreground">
                Add employees who already have a Bull Wave Rides user account.
              </p>
            </div>
          </div>
          <Button variant="outline" onClick={logout}>
            <LogOut className="mr-2 h-4 w-4" />
            Logout
          </Button>
        </div>

        {loading && (
          <div className="flex items-center gap-2 text-muted-foreground">
            <Loader2 className="h-4 w-4 animate-spin" />
            Loading…
          </div>
        )}

        {error && !loading && (
          <p className="mb-4 rounded-xl bg-destructive/10 px-3 py-2 text-sm text-destructive">
            {error}
          </p>
        )}

        {profile && (
          <div className="mb-6 rounded-2xl border border-border bg-card p-5">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <div>
                <p className="text-lg font-semibold">{profile.company_name}</p>
                <p className="text-sm text-muted-foreground">
                  Code: {profile.company_code} · {profile.email}
                </p>
              </div>
              <span className="rounded-full bg-primary/10 px-3 py-1 text-xs font-semibold text-primary">
                {profile.status}
              </span>
            </div>
            {profile.status !== "APPROVED" && (
              <p className="mt-3 text-sm text-amber-700">
                Your company is not approved yet. Employee corporate rides work only after
                platform admin approval. You can still prepare the employee list.
              </p>
            )}
          </div>
        )}

        <div className="mb-8 rounded-2xl border border-border bg-card p-5">
          <h2 className="mb-4 flex items-center gap-2 font-semibold">
            <UserPlus className="h-4 w-4" />
            Add employee
          </h2>
          <form onSubmit={onAdd} className="grid gap-3 sm:grid-cols-2">
            <div className="space-y-2">
              <Label>User phone *</Label>
              <Input
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="Same phone used in user app"
                required
                className="h-11 rounded-xl"
              />
            </div>
            <div className="space-y-2">
              <Label>Employee code *</Label>
              <Input
                value={employeeCode}
                onChange={(e) => setEmployeeCode(e.target.value)}
                placeholder="e.g. EMP001"
                required
                className="h-11 rounded-xl"
              />
            </div>
            <div className="space-y-2">
              <Label>Department</Label>
              <Input
                value={department}
                onChange={(e) => setDepartment(e.target.value)}
                className="h-11 rounded-xl"
              />
            </div>
            <div className="space-y-2">
              <Label>Designation</Label>
              <Input
                value={designation}
                onChange={(e) => setDesignation(e.target.value)}
                className="h-11 rounded-xl"
              />
            </div>
            {addError && (
              <p className="sm:col-span-2 rounded-xl bg-destructive/10 px-3 py-2 text-sm text-destructive">
                {addError}
              </p>
            )}
            <div className="sm:col-span-2">
              <Button type="submit" disabled={adding}>
                {adding ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Adding…
                  </>
                ) : (
                  <>
                    <Plus className="mr-2 h-4 w-4" />
                    Add employee
                  </>
                )}
              </Button>
            </div>
          </form>
        </div>

        <div className="rounded-2xl border border-border bg-card p-5">
          <h2 className="mb-4 font-semibold">Employees ({employees.length})</h2>
          {employees.length === 0 ? (
            <p className="text-sm text-muted-foreground">No employees linked yet.</p>
          ) : (
            <div className="space-y-3">
              {employees.map((emp) => (
                <div
                  key={emp.id}
                  className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-border px-4 py-3"
                >
                  <div>
                    <p className="font-medium">{emp.employee_name || "Employee"}</p>
                    <p className="text-xs text-muted-foreground">
                      {emp.employee_code}
                      {emp.phone ? ` · ${emp.phone}` : ""}
                      {emp.department ? ` · ${emp.department}` : ""}
                      {" · "}
                      {emp.status}
                    </p>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {emp.status === "ACTIVE" ? (
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={async () => {
                          await setMyEmployeeStatus(emp.id, "deactivate");
                          await load();
                        }}
                      >
                        Deactivate
                      </Button>
                    ) : (
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={async () => {
                          await setMyEmployeeStatus(emp.id, "activate");
                          await load();
                        }}
                      >
                        Activate
                      </Button>
                    )}
                    <Button
                      size="sm"
                      variant="destructive"
                      onClick={async () => {
                        if (!confirm("Remove this employee?")) return;
                        await removeMyEmployee(emp.id);
                        await load();
                      }}
                    >
                      Remove
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <p className="mt-6 text-center text-sm text-muted-foreground">
          Need to register another company?{" "}
          <Link href={ROUTES.corporateRegister} className="text-primary">
            Register
          </Link>
        </p>
      </main>
    </div>
  );
}
