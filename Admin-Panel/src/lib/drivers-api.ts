import { apiFetch, resolveMediaUrl } from "@/lib/api";
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
  driverCommissionPercentage?: number;
  driverEarning?: number;
  companyEarning?: number;
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
    avatar: resolveMediaUrl(driver.avatar) ?? driver.avatar,
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
    `/api/v1/admin/drivers${qs ? `?${qs}` : ""}`,
  );

  const items = Array.isArray(response.items) ? response.items : [];

  return {
    ...response,
    items: items.map(normalizeDriver),
  };
}

export async function fetchDriver(driverId: string): Promise<Driver> {
  const driver = await apiFetch<
    Driver & {
      earnings?: number | string;
      walletBalance?: number | string;
      rating?: number | string;
    }
  >(`/api/v1/admin/drivers/${driverId}`);
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
  >(`/api/v1/admin/drivers/${driverId}`, {
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
  >(`/api/v1/admin/drivers/${driverId}/approve`, { method: "POST" });
  return normalizeDriver(driver);
}

export async function rejectDriver(driverId: string): Promise<Driver> {
  const driver = await apiFetch<
    Driver & {
      earnings?: number | string;
      walletBalance?: number | string;
      rating?: number | string;
    }
  >(`/api/v1/admin/drivers/${driverId}/reject`, { method: "POST" });
  return normalizeDriver(driver);
}

export async function suspendDriver(driverId: string): Promise<Driver> {
  const driver = await apiFetch<
    Driver & {
      earnings?: number | string;
      walletBalance?: number | string;
      rating?: number | string;
    }
  >(`/api/v1/admin/drivers/${driverId}/suspend`, { method: "POST" });
  return normalizeDriver(driver);
}

export async function reactivateDriver(driverId: string): Promise<Driver> {
  const driver = await apiFetch<
    Driver & {
      earnings?: number | string;
      walletBalance?: number | string;
      rating?: number | string;
    }
  >(`/api/v1/admin/drivers/${driverId}/reactivate`, { method: "POST" });
  return normalizeDriver(driver);
}

export async function deleteDriver(driverId: string): Promise<void> {
  await apiFetch(`/api/v1/admin/drivers/${driverId}`, { method: "DELETE" });
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
  >(`/api/v1/admin/drivers/${driverId}/rides`);
  return rides.map((ride) => ({
    ...ride,
    fare: Number(ride.fare),
    distance: Number(ride.distance),
    driverCommissionPercentage:
      ride.driverCommissionPercentage != null
        ? Number(ride.driverCommissionPercentage)
        : undefined,
    driverEarning:
      ride.driverEarning != null ? Number(ride.driverEarning) : undefined,
    companyEarning:
      ride.companyEarning != null ? Number(ride.companyEarning) : undefined,
  }));
}

export async function fetchDriverDocuments(
  driverId: string,
): Promise<DriverDocument[]> {
  const response = await apiFetch<{ documents: DriverDocument[] }>(
    `/api/v1/admin/drivers/${driverId}/documents`,
  );
  return response.documents.map((doc) => ({
    ...doc,
    url: resolveMediaUrl(doc.url) ?? undefined,
  }));
}

export interface DriverWalletTransaction {
  id: string;
  type: string;
  amount: number;
  description: string;
  balanceAfter: number;
  date: string | null;
}

export interface DriverWalletSummary {
  availableBalance: number;
  pendingBalance: number;
  lifetimeEarnings: number;
  total: number;
  transactions: DriverWalletTransaction[];
}

export async function fetchDriverWallet(
  driverId: string,
): Promise<DriverWalletSummary> {
  const data = await apiFetch<DriverWalletSummary>(
    `/api/v1/admin/drivers/${driverId}/wallet`,
  );
  return {
    ...data,
    availableBalance: Number(data.availableBalance),
    pendingBalance: Number(data.pendingBalance),
    lifetimeEarnings: Number(data.lifetimeEarnings),
    transactions: (data.transactions || []).map((tx) => ({
      ...tx,
      amount: Number(tx.amount),
      balanceAfter: Number(tx.balanceAfter),
    })),
  };
}

export async function creditDriverWallet(
  driverId: string,
  amount: number,
  note?: string,
): Promise<DriverWalletSummary> {
  const data = await apiFetch<{
    availableBalance: number;
    pendingBalance: number;
    lifetimeEarnings: number;
    transaction: DriverWalletTransaction;
  }>(`/api/v1/admin/drivers/${driverId}/wallet/credit`, {
    method: "POST",
    body: JSON.stringify({ amount, note }),
  });
  return fetchDriverWallet(driverId);
}

export async function updateDriverBank(
  driverId: string,
  payload: {
    accountHolder: string;
    accountNumber: string;
    ifsc: string;
    bankName: string;
    upiId?: string;
  },
): Promise<Driver["bankDetails"]> {
  return apiFetch(`/api/v1/admin/drivers/${driverId}/bank`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}
