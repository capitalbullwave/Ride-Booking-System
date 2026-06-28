import { apiFetch } from "@/lib/api";
import { Driver, DriverStatus, VehicleType } from "@/types";

export interface PaginatedDriversResponse {
  items: Driver[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}

export interface DriverUpdatePayload {
  name?: string;
  phone?: string;
  email?: string;
  city?: string;
  vehicleType?: VehicleType;
  vehicleNumber?: string;
  status?: DriverStatus;
  joinedDate?: string;
}

export interface DriverRide {
  id: string;
  userId: string;
  userName: string;
  driverId?: string;
  driverName?: string;
  vehicleType: string;
  pickupLocation: string;
  dropLocation: string;
  distance: number;
  fare: number;
  status: string;
  date: string;
  duration?: number;
  paymentMethod: string;
}

export interface DriverDocument {
  id: string;
  driverId: string;
  type: string;
  name: string;
  status: string;
  uploadedAt: string;
  url?: string;
}

function normalizeDriver(
  driver: Driver & {
    earnings?: number | string;
    walletBalance?: number | string;
    rating?: number | string;
  },
): Driver {
  return {
    ...driver,
    earnings: Number(driver.earnings),
    walletBalance: Number(driver.walletBalance),
    rating: Number(driver.rating),
  };
}

export async function fetchDrivers(params?: {
  search?: string;
  status?: string;
  page?: number;
  limit?: number;
}): Promise<PaginatedDriversResponse> {
  const query = new URLSearchParams();
  if (params?.search) query.set("search", params.search);
  if (params?.status && params.status !== "all") query.set("status", params.status);
  if (params?.page) query.set("page", String(params.page));
  if (params?.limit) query.set("limit", String(params.limit));

  const qs = query.toString();
  const response = await apiFetch<PaginatedDriversResponse>(
    `/api/v1/drivers${qs ? `?${qs}` : ""}`,
  );

  return {
    ...response,
    items: response.items.map(normalizeDriver),
  };
}

export async function fetchDriver(driverId: string): Promise<Driver> {
  const driver = await apiFetch<
    Driver & {
      earnings?: number | string;
      walletBalance?: number | string;
      rating?: number | string;
    }
  >(`/api/v1/drivers/${driverId}`);
  return normalizeDriver(driver);
}

export async function updateDriver(
  driverId: string,
  data: DriverUpdatePayload,
): Promise<Driver> {
  const driver = await apiFetch<
    Driver & {
      earnings?: number | string;
      walletBalance?: number | string;
      rating?: number | string;
    }
  >(`/api/v1/drivers/${driverId}`, {
    method: "PATCH",
    body: JSON.stringify(data),
  });
  return normalizeDriver(driver);
}

export async function approveDriver(driverId: string): Promise<Driver> {
  const driver = await apiFetch<
    Driver & {
      earnings?: number | string;
      walletBalance?: number | string;
      rating?: number | string;
    }
  >(`/api/v1/drivers/${driverId}/approve`, { method: "POST" });
  return normalizeDriver(driver);
}

export async function rejectDriver(driverId: string): Promise<Driver> {
  const driver = await apiFetch<
    Driver & {
      earnings?: number | string;
      walletBalance?: number | string;
      rating?: number | string;
    }
  >(`/api/v1/drivers/${driverId}/reject`, { method: "POST" });
  return normalizeDriver(driver);
}

export async function suspendDriver(driverId: string): Promise<Driver> {
  const driver = await apiFetch<
    Driver & {
      earnings?: number | string;
      walletBalance?: number | string;
      rating?: number | string;
    }
  >(`/api/v1/drivers/${driverId}/suspend`, { method: "POST" });
  return normalizeDriver(driver);
}

export async function reactivateDriver(driverId: string): Promise<Driver> {
  const driver = await apiFetch<
    Driver & {
      earnings?: number | string;
      walletBalance?: number | string;
      rating?: number | string;
    }
  >(`/api/v1/drivers/${driverId}/reactivate`, { method: "POST" });
  return normalizeDriver(driver);
}

export async function setDriverStatus(
  driverId: string,
  status: DriverStatus,
): Promise<Driver> {
  return updateDriver(driverId, { status });
}

export async function fetchDriverRides(driverId: string): Promise<DriverRide[]> {
  const rides = await apiFetch<
    (DriverRide & { fare?: number | string; distance?: number | string })[]
  >(`/api/v1/drivers/${driverId}/rides`);
  return rides.map((ride) => ({
    ...ride,
    fare: Number(ride.fare),
    distance: Number(ride.distance),
  }));
}

export async function fetchDriverDocuments(
  driverId: string,
): Promise<DriverDocument[]> {
  const response = await apiFetch<{ documents: DriverDocument[] }>(
    `/api/v1/drivers/${driverId}/documents`,
  );
  return response.documents;
}
