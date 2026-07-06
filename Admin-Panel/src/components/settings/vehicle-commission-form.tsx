"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { Percent, Save } from "lucide-react";
import { toast } from "sonner";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  fetchCommissionSettings,
  updateCommissionSettings,
  type VehicleCommissionSettings,
} from "@/lib/commission-api";
import { formatDateTime } from "@/lib/format";

function FieldHint({ children }: { children: React.ReactNode }) {
  return <p className="text-xs text-muted-foreground">{children}</p>;
}

function serviceGroupLabel(group: string) {
  if (group === "rental") return "Rental";
  if (group === "parcel") return "Parcel";
  return "Ride";
}

type VehicleCommissionFormProps = {
  enabled?: boolean;
  onSaved?: (settings: VehicleCommissionSettings) => void;
};

export function VehicleCommissionForm({
  enabled = true,
  onSaved,
}: VehicleCommissionFormProps) {
  const [settings, setSettings] = useState<VehicleCommissionSettings | null>(null);
  const [defaultPercentage, setDefaultPercentage] = useState(0);
  const [vehiclePercentages, setVehiclePercentages] = useState<Record<string, number>>({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [isDirty, setIsDirty] = useState(false);

  const load = useCallback(async () => {
    if (!enabled) return;
    try {
      setLoading(true);
      const data = await fetchCommissionSettings();
      setSettings(data);
      setDefaultPercentage(data.defaultCommissionPercentage);
      setVehiclePercentages(
        Object.fromEntries(
          data.vehicles.map((vehicle) => [vehicle.vehicleTypeId, vehicle.driverCommissionPercentage]),
        ),
      );
      setIsDirty(false);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to load commission settings");
    } finally {
      setLoading(false);
    }
  }, [enabled]);

  useEffect(() => {
    void load();
  }, [load]);

  const isValid = useMemo(() => {
    if (defaultPercentage < 0 || defaultPercentage > 100) return false;
    return Object.values(vehiclePercentages).every((value) => value >= 0 && value <= 100);
  }, [defaultPercentage, vehiclePercentages]);

  const handleSave = async () => {
    if (!settings || !isValid) {
      toast.error("Commission must be between 0 and 100 for all vehicles");
      return;
    }
    try {
      setSaving(true);
      const updated = await updateCommissionSettings({
        defaultCommissionPercentage: defaultPercentage,
        vehicles: settings.vehicles.map((vehicle) => ({
          vehicleTypeId: vehicle.vehicleTypeId,
          driverCommissionPercentage:
            vehiclePercentages[vehicle.vehicleTypeId] ?? vehicle.driverCommissionPercentage,
        })),
      });
      setSettings(updated);
      setDefaultPercentage(updated.defaultCommissionPercentage);
      setVehiclePercentages(
        Object.fromEntries(
          updated.vehicles.map((vehicle) => [vehicle.vehicleTypeId, vehicle.driverCommissionPercentage]),
        ),
      );
      setIsDirty(false);
      toast.success("Commission saved — new rides will use these rates");
      onSaved?.(updated);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to save commission settings");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="rounded-[1.25rem] border border-primary/15 bg-primary/5 px-4 py-3 text-sm text-muted-foreground">
        Rates are loaded from the database — not hardcoded. Save here to update commission for future completed rides.
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="rounded-lg bg-primary/10 p-2">
              <Percent className="h-5 w-5 text-primary" />
            </div>
            <div>
              <CardTitle>Default Fallback</CardTitle>
              <CardDescription>
                Used when a ride has no vehicle type or a vehicle has no commission set.
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-2">
          <Label htmlFor="default-commission">Default Commission (%)</Label>
          <FieldHint>Must be between 0 and 100.</FieldHint>
          <Input
            id="default-commission"
            type="number"
            min={0}
            max={100}
            step={0.1}
            className="max-w-sm"
            value={defaultPercentage}
            disabled={loading}
            onChange={(e) => {
              setDefaultPercentage(Number(e.target.value));
              setIsDirty(true);
            }}
          />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Commission by Vehicle</CardTitle>
          <CardDescription>
            Each completed ride uses the commission rate for the booked vehicle type.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <p className="text-sm text-muted-foreground">Loading vehicles...</p>
          ) : !settings?.vehicles.length ? (
            <p className="text-sm text-muted-foreground">
              No vehicle types found. Add vehicles under Vehicle Management first.
            </p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Vehicle</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead className="w-[180px]">Driver Commission (%)</TableHead>
                  <TableHead>Example on ₹500</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {settings.vehicles.map((vehicle) => {
                  const percentage =
                    vehiclePercentages[vehicle.vehicleTypeId] ?? vehicle.driverCommissionPercentage;
                  const driverShare = Math.round((500 * percentage) / 100);
                  return (
                    <TableRow key={vehicle.vehicleTypeId}>
                      <TableCell>
                        <div className="font-medium">{vehicle.name}</div>
                        <div className="text-xs text-muted-foreground">{vehicle.slug}</div>
                      </TableCell>
                      <TableCell>
                        <Badge variant="secondary">{serviceGroupLabel(vehicle.serviceGroup)}</Badge>
                      </TableCell>
                      <TableCell>
                        <Input
                          type="number"
                          min={0}
                          max={100}
                          step={0.1}
                          value={percentage}
                          disabled={!vehicle.isActive}
                          onChange={(e) => {
                            setVehiclePercentages((prev) => ({
                              ...prev,
                              [vehicle.vehicleTypeId]: Number(e.target.value),
                            }));
                            setIsDirty(true);
                          }}
                        />
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        Driver ₹{driverShare} · Company ₹{500 - driverShare}
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          )}

          {!isValid && (
            <p className="mt-4 text-sm text-destructive">
              All commission values must be between 0 and 100.
            </p>
          )}

          {settings?.updatedAt && (
            <div className="mt-6 rounded-[1rem] border bg-muted/30 px-4 py-3 text-sm text-muted-foreground">
              <p>
                <span className="font-medium text-foreground">Last updated:</span>{" "}
                {formatDateTime(settings.updatedAt)}
              </p>
              {settings.updatedByName && (
                <p className="mt-1">
                  <span className="font-medium text-foreground">Updated by:</span>{" "}
                  {settings.updatedByName}
                </p>
              )}
            </div>
          )}
        </CardContent>
      </Card>

      <div className="flex justify-end pb-2">
        <Button onClick={handleSave} disabled={!isDirty || !isValid || saving || loading}>
          <Save className="mr-2 h-4 w-4" />
          {saving ? "Saving..." : "Save Commission"}
        </Button>
      </div>
    </div>
  );
}
