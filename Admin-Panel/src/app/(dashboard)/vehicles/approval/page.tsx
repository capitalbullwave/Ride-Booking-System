"use client";

import { ArrowLeft, CheckCircle, XCircle, FileText } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { drivers } from "@/data/mock-data";
import { formatDate, capitalize } from "@/lib/format";

const pendingDrivers = drivers.filter((d) => d.status === "pending" || d.status === "rejected");

export default function VehicleApprovalPage() {
  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <ButtonLink variant="ghost" size="icon" href="/vehicles">
          <ArrowLeft className="h-4 w-4" />
        </ButtonLink>
        <PageHeader
          title="Vehicle Approval"
          description="Review and verify vehicle documents"
        />
      </div>

      <div className="grid gap-6">
        {pendingDrivers.map((driver) => (
          <Card key={driver.id}>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle>{driver.name}</CardTitle>
                  <p className="text-sm text-muted-foreground">
                    {capitalize(driver.vehicleType)} · {driver.vehicleNumber} · Applied {formatDate(driver.joinedDate)}
                  </p>
                </div>
                <StatusBadge status={driver.status} />
              </div>
            </CardHeader>
            <CardContent>
              <div className="grid gap-4 sm:grid-cols-3">
                {[
                  { name: "Vehicle Verification", status: "pending" },
                  { name: "Insurance Verification", status: "pending" },
                  { name: "RC Verification", status: "approved" },
                ].map((doc) => (
                  <div key={doc.name} className="rounded-lg border p-4">
                    <div className="flex items-center gap-3">
                      <FileText className="h-5 w-5 text-muted-foreground" />
                      <div className="flex-1">
                        <p className="text-sm font-medium">{doc.name}</p>
                        <StatusBadge status={doc.status} />
                      </div>
                    </div>
                    <div className="mt-3 flex gap-2">
                      <Button size="sm" variant="outline" className="flex-1">View</Button>
                      <Button size="sm" className="flex-1">
                        <CheckCircle className="mr-1 h-3 w-3" /> Approve
                      </Button>
                      <Button size="sm" variant="destructive" className="flex-1">
                        <XCircle className="mr-1 h-3 w-3" /> Reject
                      </Button>
                    </div>
                  </div>
                ))}
              </div>
              <div className="mt-4 flex justify-end gap-2">
                <ButtonLink variant="outline" href={`/drivers/${driver.id}`}>
                  View Driver Profile
                </ButtonLink>
                <Button variant="destructive">
                  <XCircle className="mr-2 h-4 w-4" /> Reject All
                </Button>
                <Button>
                  <CheckCircle className="mr-2 h-4 w-4" /> Approve All
                </Button>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
