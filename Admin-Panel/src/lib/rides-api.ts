import { apiFetch } from "@/lib/api";
import { Ride, RideStatus, VehicleType } from "@/types";

export interface PaginatedRidesResponse {
  items: Ride[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}

type RideApiItem = Ride & {
  fare?: number | string | null;
  distance?: number | string | null;
  duration?: number | string | null;
  vehicleType?: string;
};

function normalizeVehicleType(value: string | undefined): VehicleType {
  const normalized = (value ?? "sedan").toLowerCase().replace(/\s+/g, "_");
  const allowed: VehicleType[] = ["bike", "auto", "mini_cab", "sedan", "suv"];
  return allowed.includes(normalized as VehicleType)
    ? (normalized as VehicleType)
    : "sedan";
}

function normalizeRide(ride: RideApiItem): Ride {
  return {
    ...ride,
    vehicleType: normalizeVehicleType(ride.vehicleType),
    distance: Number(ride.distance ?? 0),
    fare: Number(ride.fare ?? 0),
    driverCommissionPercentage:
      ride.driverCommissionPercentage != null
        ? Number(ride.driverCommissionPercentage)
        : undefined,
    driverEarning:
      ride.driverEarning != null ? Number(ride.driverEarning) : undefined,
    companyEarning:
      ride.companyEarning != null ? Number(ride.companyEarning) : undefined,
    duration: ride.duration != null ? Number(ride.duration) : undefined,
    paymentMethod: ride.paymentMethod ?? "cash",
    status: (ride.status ?? "requested") as RideStatus,
  };
}

export async function fetchRides(params?: {
  search?: string;
  status?: string;
  page?: number;
  limit?: number;
}): Promise<PaginatedRidesResponse> {
  const query = new URLSearchParams();
  if (params?.search) query.set("search", params.search);
  if (params?.status && params.status !== "all") query.set("status", params.status);
  if (params?.page) query.set("page", String(params.page));
  if (params?.limit) query.set("limit", String(params.limit));

  const qs = query.toString();
  const response = await apiFetch<PaginatedRidesResponse>(
    `/api/v1/admin/rides${qs ? `?${qs}` : ""}`,
  );

  const items = Array.isArray(response.items) ? response.items : [];

  return {
    ...response,
    items: items.map(normalizeRide),
  };
}

export async function fetchRideById(rideId: string): Promise<Ride> {
  const ride = await apiFetch<RideApiItem>(`/api/v1/admin/rides/${rideId}`);
  return normalizeRide(ride);
}

export interface RideChatMessage {
  id: string;
  ride_id: string;
  sender_id: string;
  sender_type: string;
  sender_name?: string | null;
  message: string;
  created_at?: string | null;
}

export async function fetchRideMessages(rideId: string): Promise<RideChatMessage[]> {
  const response = await apiFetch<{ success?: boolean; data?: RideChatMessage[] }>(
    `/api/v1/admin/rides/${rideId}/messages`,
  );
  return Array.isArray(response.data) ? response.data : [];
}
