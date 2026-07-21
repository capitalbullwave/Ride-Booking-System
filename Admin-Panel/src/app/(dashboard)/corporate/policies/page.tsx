"use client";

import { useCallback, useEffect, useState } from "react";
import { PageHeader } from "@/components/layout/page-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
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
  getCorporatePolicy,
  listCorporateCompanies,
  upsertCorporatePolicy,
  type CorporateCompany,
  type CorporatePolicy,
} from "@/lib/corporate-api";
import { toast } from "sonner";

export default function CorporatePoliciesPage() {
  const [companies, setCompanies] = useState<CorporateCompany[]>([]);
  const [companyId, setCompanyId] = useState("");
  const [policy, setPolicy] = useState<CorporatePolicy | null>(null);
  const [maxRideAmount, setMaxRideAmount] = useState("");
  const [approvalRequired, setApprovalRequired] = useState(false);
  const [purposeRequired, setPurposeRequired] = useState(false);

  useEffect(() => {
    void listCorporateCompanies({ status: "APPROVED", limit: 100 }).then((d) => {
      setCompanies(d.items);
      if (d.items[0]) setCompanyId(d.items[0].id);
    });
  }, []);

  const load = useCallback(async () => {
    if (!companyId) return;
    try {
      const p = await getCorporatePolicy(companyId);
      setPolicy(p);
      setMaxRideAmount(p.max_ride_amount != null ? String(p.max_ride_amount) : "");
      setApprovalRequired(p.approval_required);
      setPurposeRequired(p.purpose_required);
    } catch {
      setPolicy(null);
      setMaxRideAmount("");
      setApprovalRequired(false);
      setPurposeRequired(false);
    }
  }, [companyId]);

  useEffect(() => {
    void load();
  }, [load]);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Ride Policies"
        description="Configure vehicle, fare, and office-hour rules per company."
      />

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

      <Card className="max-w-xl">
        <CardHeader>
          <CardTitle>{policy ? "Edit Policy" : "Create Policy"}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label>Max ride amount (₹)</Label>
            <Input
              type="number"
              value={maxRideAmount}
              onChange={(e) => setMaxRideAmount(e.target.value)}
              placeholder="Leave empty for unlimited"
            />
          </div>
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={approvalRequired}
              onChange={(e) => setApprovalRequired(e.target.checked)}
            />
            Approval required
          </label>
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={purposeRequired}
              onChange={(e) => setPurposeRequired(e.target.checked)}
            />
            Purpose required
          </label>
          <Button
            disabled={!companyId}
            onClick={async () => {
              try {
                await upsertCorporatePolicy(companyId, {
                  max_ride_amount: maxRideAmount ? Number(maxRideAmount) : null,
                  approval_required: approvalRequired,
                  purpose_required: purposeRequired,
                  working_days: [0, 1, 2, 3, 4],
                });
                toast.success("Policy saved");
                void load();
              } catch (e) {
                toast.error(e instanceof Error ? e.message : "Save failed");
              }
            }}
          >
            Save Policy
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
