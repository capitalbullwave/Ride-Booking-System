"use client";

import { useState } from "react";
import { Bike, Car, Truck, Save } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import { vehicleCategories } from "@/data/mock-data";
import { toast } from "sonner";
import { VehicleCategory } from "@/types";

const vehicleIcons: Record<string, typeof Bike> = {
  bike: Bike,
  auto: Car,
  mini_cab: Car,
  sedan: Car,
  suv: Truck,
};

export default function VehiclesPage() {
  const [categories, setCategories] = useState(vehicleCategories);

  const updateCategory = (id: string, field: keyof VehicleCategory, value: number | boolean) => {
    setCategories((prev) =>
      prev.map((cat) => (cat.id === id ? { ...cat, [field]: value } : cat))
    );
  };

  const handleSave = () => {
    toast.success("Vehicle settings saved successfully");
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Vehicle Management" description="Configure vehicle categories and pricing">
        <ButtonLink variant="outline" href="/vehicles/approval">
          Vehicle Approval
        </ButtonLink>
        <Button onClick={handleSave}>
          <Save className="mr-2 h-4 w-4" /> Save Changes
        </Button>
      </PageHeader>

      <div className="grid gap-6">
        {categories.map((category) => {
          const Icon = vehicleIcons[category.type] ?? Car;
          return (
            <Card key={category.id}>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="rounded-lg bg-primary/10 p-3">
                      <Icon className="h-6 w-6 text-primary" />
                    </div>
                    <div>
                      <CardTitle>{category.name}</CardTitle>
                      <CardDescription>Configure pricing for {category.name.toLowerCase()}</CardDescription>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <Badge variant={category.isActive ? "default" : "secondary"}>
                      {category.isActive ? "Active" : "Inactive"}
                    </Badge>
                    <Switch
                      checked={category.isActive}
                      onCheckedChange={(checked) => updateCategory(category.id, "isActive", checked)}
                    />
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
                  <div className="space-y-2">
                    <Label>Base Fare (₹)</Label>
                    <Input
                      type="number"
                      value={category.baseFare}
                      onChange={(e) => updateCategory(category.id, "baseFare", Number(e.target.value))}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>Per KM Fare (₹)</Label>
                    <Input
                      type="number"
                      value={category.perKmFare}
                      onChange={(e) => updateCategory(category.id, "perKmFare", Number(e.target.value))}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>Waiting Charge (₹/min)</Label>
                    <Input
                      type="number"
                      value={category.waitingCharge}
                      onChange={(e) => updateCategory(category.id, "waitingCharge", Number(e.target.value))}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>Cancellation Charge (₹)</Label>
                    <Input
                      type="number"
                      value={category.cancellationCharge}
                      onChange={(e) => updateCategory(category.id, "cancellationCharge", Number(e.target.value))}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>Surge Multiplier (x)</Label>
                    <Input
                      type="number"
                      step="0.1"
                      value={category.surgeMultiplier}
                      onChange={(e) => updateCategory(category.id, "surgeMultiplier", Number(e.target.value))}
                    />
                  </div>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
