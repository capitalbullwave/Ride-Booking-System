"use client";

import { PageHeader } from "@/components/layout/page-header";
import { VehicleCommissionForm } from "@/components/settings/vehicle-commission-form";

export default function DriverCommissionSettingsPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Driver Commission"
        description="Set driver commission percentage for each vehicle type. Drivers earn that share of the ride fare when a trip is completed."
      />
      <VehicleCommissionForm />
    </div>
  );
}
