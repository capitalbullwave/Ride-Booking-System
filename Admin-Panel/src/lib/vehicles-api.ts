import { apiFetch } from "@/lib/api";
import { VehicleCategory } from "@/types";

export interface CreateVehicleCategoryPayload {
  name: string;
  description?: string;
  icon?: string;
  baseFare?: number;
  perKmFare?: number;
  includedDistanceKm?: number;
  includedHours?: number;
  perHourRate?: number;
  waitingCharge?: number;
  cancellationCharge?: number;
  capacity?: number;
  isActive?: boolean;
  image?: string;
  serviceGroup?: "ride" | "rental";
}

export interface UpdateVehicleCategoryPayload {
  name?: string;
  description?: string;
  icon?: string;
  baseFare?: number;
  perKmFare?: number;
  includedDistanceKm?: number;
  includedHours?: number;
  perHourRate?: number;
  waitingCharge?: number;
  cancellationCharge?: number;
  isActive?: boolean;
  capacity?: number;
  image?: string;
}

export function listVehicleCategories(): Promise<VehicleCategory[]> {
  return apiFetch<VehicleCategory[]>("/api/v1/admin/vehicle-categories");
}

export function createVehicleCategory(
  payload: CreateVehicleCategoryPayload,
): Promise<VehicleCategory> {
  return apiFetch<VehicleCategory>("/api/v1/admin/vehicle-categories", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function updateVehicleCategory(
  id: string,
  payload: UpdateVehicleCategoryPayload,
): Promise<VehicleCategory> {
  return apiFetch<VehicleCategory>(`/api/v1/admin/vehicle-categories/${id}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}

export function deleteVehicleCategory(
  id: string,
): Promise<{ success: boolean; deactivated?: boolean }> {
  return apiFetch<{ success: boolean; deactivated?: boolean }>(
    `/api/v1/admin/vehicle-categories/${id}`,
    { method: "DELETE" },
  );
}

export function reorderVehicleCategories(
  items: { id: string; displayOrder: number }[],
): Promise<{ success: boolean }> {
  return apiFetch<{ success: boolean }>("/api/v1/admin/vehicle-categories/reorder", {
    method: "POST",
    body: JSON.stringify({ items }),
  });
}
