import { apiFetch } from "@/lib/api";

export type VehicleCommissionItem = {
  vehicleTypeId: string;
  name: string;
  slug: string;
  serviceGroup: string;
  driverCommissionPercentage: number;
  isActive: boolean;
};

export type VehicleCommissionSettings = {
  defaultCommissionPercentage: number;
  updatedAt?: string;
  updatedByName?: string;
  vehicles: VehicleCommissionItem[];
};

/** @deprecated Use VehicleCommissionSettings */
export type CommissionSettings = {
  id: string;
  driverCommissionPercentage: number;
  isActive: boolean;
  updatedBy?: string;
  updatedByName?: string;
  createdAt: string;
  updatedAt: string;
};

function mapVehicleCommissionItem(raw: Record<string, unknown>): VehicleCommissionItem {
  return {
    vehicleTypeId: String(raw.vehicle_type_id ?? raw.vehicleTypeId ?? ""),
    name: String(raw.name ?? ""),
    slug: String(raw.slug ?? ""),
    serviceGroup: String(raw.service_group ?? raw.serviceGroup ?? "ride"),
    driverCommissionPercentage: Number(
      raw.driver_commission_percentage ?? raw.driverCommissionPercentage ?? 0,
    ),
    isActive: Boolean(raw.is_active ?? raw.isActive ?? true),
  };
}

function mapVehicleCommissionSettings(raw: Record<string, unknown>): VehicleCommissionSettings {
  const vehicles = Array.isArray(raw.vehicles) ? raw.vehicles : [];
  return {
    defaultCommissionPercentage: Number(
      raw.default_commission_percentage ?? raw.defaultCommissionPercentage ?? 0,
    ),
    updatedAt:
      raw.updated_at != null
        ? String(raw.updated_at)
        : raw.updatedAt != null
          ? String(raw.updatedAt)
          : undefined,
    updatedByName:
      raw.updated_by_name != null
        ? String(raw.updated_by_name)
        : raw.updatedByName != null
          ? String(raw.updatedByName)
          : undefined,
    vehicles: vehicles.map((item) => mapVehicleCommissionItem((item ?? {}) as Record<string, unknown>)),
  };
}

export async function fetchCommissionSettings(): Promise<VehicleCommissionSettings> {
  const res = await apiFetch<Record<string, unknown>>("/api/v1/admin/commission-settings");
  return mapVehicleCommissionSettings(res);
}

export async function updateCommissionSettings(payload: {
  defaultCommissionPercentage?: number;
  vehicles: Array<{ vehicleTypeId: string; driverCommissionPercentage: number }>;
}): Promise<VehicleCommissionSettings> {
  const res = await apiFetch<Record<string, unknown>>("/api/v1/admin/commission-settings", {
    method: "PUT",
    body: JSON.stringify({
      default_commission_percentage: payload.defaultCommissionPercentage,
      vehicles: payload.vehicles.map((item) => ({
        vehicle_type_id: item.vehicleTypeId,
        driver_commission_percentage: item.driverCommissionPercentage,
      })),
    }),
  });
  return mapVehicleCommissionSettings(res);
}

export type RevenueReportItem = {
  date?: string;
  driverId?: string;
  totalRideRevenue: number;
  totalDriverEarnings: number;
  totalCompanyEarnings: number;
  completedRides: number;
};

export type RevenueReport = {
  groupBy: "date" | "driver";
  driverCommissionPercentage?: number;
  totals?: {
    totalRideRevenue: number;
    totalDriverEarnings: number;
    totalCompanyEarnings: number;
    completedRides: number;
  };
  items: RevenueReportItem[];
};

export async function fetchRevenueReport(params?: {
  groupBy?: "date" | "driver";
  days?: number;
}): Promise<RevenueReport> {
  const query = new URLSearchParams();
  if (params?.groupBy) query.set("group_by", params.groupBy);
  if (params?.days) query.set("days", String(params.days));
  const qs = query.toString();
  const res = await apiFetch<Record<string, unknown>>(
    `/api/v1/admin/reports/revenue${qs ? `?${qs}` : ""}`,
  );

  const items = Array.isArray(res.items) ? res.items : [];
  return {
    groupBy: (res.groupBy as "date" | "driver") ?? "date",
    driverCommissionPercentage: Number(res.driverCommissionPercentage ?? 0),
    totals: res.totals
      ? {
          totalRideRevenue: Number((res.totals as Record<string, unknown>).totalRideRevenue ?? 0),
          totalDriverEarnings: Number((res.totals as Record<string, unknown>).totalDriverEarnings ?? 0),
          totalCompanyEarnings: Number((res.totals as Record<string, unknown>).totalCompanyEarnings ?? 0),
          completedRides: Number((res.totals as Record<string, unknown>).completedRides ?? 0),
        }
      : undefined,
    items: items.map((raw) => {
      const item = (raw ?? {}) as Record<string, unknown>;
      return {
        date: item.date != null ? String(item.date) : undefined,
        driverId: item.driverId != null ? String(item.driverId) : undefined,
        totalRideRevenue: Number(item.totalRideRevenue ?? 0),
        totalDriverEarnings: Number(item.totalDriverEarnings ?? 0),
        totalCompanyEarnings: Number(item.totalCompanyEarnings ?? 0),
        completedRides: Number(item.completedRides ?? 0),
      };
    }),
  };
}
