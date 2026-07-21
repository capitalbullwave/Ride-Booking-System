"use client";

import { useCallback, useEffect, useState } from "react";
import { useParams, useSearchParams } from "next/navigation";
import {
  CheckCircle,
  XCircle,
  Ban,
  Pencil,
  ArrowLeft,
} from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatusBadge } from "@/components/shared/status-badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ButtonLink } from "@/components/ui/button-link";
import { formatCurrency, formatDate } from "@/lib/format";
import {
  approveCorporateCompany,
  getCorporateCompany,
  rejectCorporateCompany,
  suspendCorporateCompany,
  updateCorporateCompany,
  type CorporateCompany,
} from "@/lib/corporate-api";
import { toast } from "sonner";

export default function CorporateCompanyDetailPage() {
  const params = useParams<{ id: string }>();
  const searchParams = useSearchParams();
  const [company, setCompany] = useState<CorporateCompany | null>(null);
  const [editing, setEditing] = useState(searchParams.get("edit") === "1");
  const [creditLimit, setCreditLimit] = useState("");
  const [contactPerson, setContactPerson] = useState("");
  const [phone, setPhone] = useState("");

  const load = useCallback(async () => {
    try {
      const data = await getCorporateCompany(params.id);
      setCompany(data);
      setCreditLimit(String(data.credit_limit ?? 0));
      setContactPerson(data.contact_person);
      setPhone(data.phone);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to load company");
    }
  }, [params.id]);

  useEffect(() => {
    void load();
  }, [load]);

  if (!company) {
    return <p className="text-muted-foreground">Loading company…</p>;
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title={company.company_name}
        description={`${company.company_code} · ${company.email}`}
      >
        <ButtonLink href="/corporate/companies" variant="outline">
          <ArrowLeft className="mr-1 h-4 w-4" />
          Back
        </ButtonLink>
      </PageHeader>

      <div className="flex flex-wrap gap-2">
        <StatusBadge status={company.status.toLowerCase()} />
        {company.status === "PENDING" && (
          <>
            <Button
              onClick={async () => {
                await approveCorporateCompany(company.id);
                toast.success("Approved");
                void load();
              }}
            >
              <CheckCircle className="mr-1 h-4 w-4" />
              Approve
            </Button>
            <Button
              variant="outline"
              onClick={async () => {
                await rejectCorporateCompany(company.id, "Rejected by admin");
                toast.success("Rejected");
                void load();
              }}
            >
              <XCircle className="mr-1 h-4 w-4" />
              Reject
            </Button>
          </>
        )}
        {company.status === "APPROVED" && (
          <Button
            variant="outline"
            onClick={async () => {
              await suspendCorporateCompany(company.id);
              toast.success("Suspended");
              void load();
            }}
          >
            <Ban className="mr-1 h-4 w-4" />
            Suspend
          </Button>
        )}
        <Button variant="secondary" onClick={() => setEditing((v) => !v)}>
          <Pencil className="mr-1 h-4 w-4" />
          Edit
        </Button>
        <ButtonLink href={`/corporate/employees?company_id=${company.id}`} variant="outline">
          Employees
        </ButtonLink>
      </div>

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {[
          ["GST", company.gst_number],
          ["PAN", company.pan_number],
          ["Website", company.website],
          ["Industry", company.industry],
          ["Company Size", company.company_size],
          ["Address", [company.address, company.city, company.state, company.country].filter(Boolean).join(", ")],
          ["Contact Person", company.contact_person],
          ["Phone", company.phone],
          ["Credit Limit", formatCurrency(company.credit_limit)],
          ["Wallet Balance", formatCurrency(company.wallet_balance)],
          ["Outstanding", formatCurrency(company.outstanding_amount ?? 0)],
          ["Current Month Spend", formatCurrency(company.current_month_spend ?? 0)],
          ["Total Employees", company.total_employees ?? company.employee_count ?? 0],
          ["Total Rides", company.total_rides ?? 0],
          ["Created", formatDate(company.created_at)],
        ].map(([label, value]) => (
          <Card key={String(label)}>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm text-muted-foreground">{label}</CardTitle>
            </CardHeader>
            <CardContent className="text-base font-medium">{value || "—"}</CardContent>
          </Card>
        ))}
      </div>

      {editing && (
        <Card>
          <CardHeader>
            <CardTitle>Edit Company</CardTitle>
          </CardHeader>
          <CardContent className="grid max-w-lg gap-4">
            <div className="space-y-2">
              <Label>Contact Person</Label>
              <Input value={contactPerson} onChange={(e) => setContactPerson(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Phone</Label>
              <Input value={phone} onChange={(e) => setPhone(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Credit Limit</Label>
              <Input
                type="number"
                value={creditLimit}
                onChange={(e) => setCreditLimit(e.target.value)}
              />
            </div>
            <Button
              onClick={async () => {
                try {
                  await updateCorporateCompany(company.id, {
                    contact_person: contactPerson,
                    phone,
                    credit_limit: Number(creditLimit) || 0,
                  });
                  toast.success("Company updated");
                  setEditing(false);
                  void load();
                } catch (e) {
                  toast.error(e instanceof Error ? e.message : "Update failed");
                }
              }}
            >
              Save changes
            </Button>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
