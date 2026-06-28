import { apiFetch } from "@/lib/api";
import { User, UserStatus } from "@/types";

export interface PaginatedUsersResponse {
  items: User[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}

export interface UserUpdatePayload {
  name?: string;
  mobile?: string;
  email?: string;
  city?: string;
  status?: UserStatus;
  registrationDate?: string;
}

function normalizeUser(user: User & { walletBalance?: number | string }): User {
  return {
    ...user,
    walletBalance: Number(user.walletBalance),
  };
}

export async function fetchUsers(params?: {
  search?: string;
  status?: string;
  page?: number;
  limit?: number;
}): Promise<PaginatedUsersResponse> {
  const query = new URLSearchParams();
  if (params?.search) query.set("search", params.search);
  if (params?.status && params.status !== "all") query.set("status", params.status);
  if (params?.page) query.set("page", String(params.page));
  if (params?.limit) query.set("limit", String(params.limit));

  const qs = query.toString();
  const response = await apiFetch<PaginatedUsersResponse>(
    `/api/v1/users${qs ? `?${qs}` : ""}`,
  );

  return {
    ...response,
    items: response.items.map(normalizeUser),
  };
}

export async function updateUser(
  userId: string,
  data: UserUpdatePayload,
): Promise<User> {
  const user = await apiFetch<User & { walletBalance?: number | string }>(
    `/api/v1/users/${userId}`,
    {
      method: "PATCH",
      body: JSON.stringify(data),
    },
  );
  return normalizeUser(user);
}

export async function suspendUser(userId: string): Promise<User> {
  const user = await apiFetch<User & { walletBalance?: number | string }>(
    `/api/v1/users/${userId}/suspend`,
    { method: "POST" },
  );
  return normalizeUser(user);
}

export async function blockUser(userId: string): Promise<User> {
  const user = await apiFetch<User & { walletBalance?: number | string }>(
    `/api/v1/users/${userId}/block`,
    { method: "POST" },
  );
  return normalizeUser(user);
}

export async function activateUser(userId: string): Promise<User> {
  const user = await apiFetch<User & { walletBalance?: number | string }>(
    `/api/v1/users/${userId}/activate`,
    { method: "POST" },
  );
  return normalizeUser(user);
}

export async function fetchUser(userId: string): Promise<User> {
  const user = await apiFetch<User & { walletBalance?: number | string }>(
    `/api/v1/users/${userId}`,
  );
  return normalizeUser(user);
}

export async function resetUser(userId: string): Promise<User> {
  const user = await apiFetch<User & { walletBalance?: number | string }>(
    `/api/v1/users/${userId}/reset`,
    { method: "POST" },
  );
  return normalizeUser(user);
}

export interface UserRide {
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

export interface WalletTransaction {
  id: string;
  userId: string;
  description: string;
  amount: number;
  status: string;
  date: string;
  rideId?: string;
}

export interface UserWallet {
  balance: number;
  transactions: WalletTransaction[];
}

export interface UserSupportTicket {
  id: string;
  userId: string;
  subject: string;
  description: string;
  status: string;
  priority: string;
  createdAt: string;
  updatedAt: string;
}

export interface UserActivityLog {
  id: string;
  userId: string;
  action: string;
  timestamp: string;
}

export async function fetchUserRides(userId: string): Promise<UserRide[]> {
  const rides = await apiFetch<
    (UserRide & { fare?: number | string; distance?: number | string })[]
  >(`/api/v1/users/${userId}/rides`);
  return rides.map((ride) => ({
    ...ride,
    fare: Number(ride.fare),
    distance: Number(ride.distance),
  }));
}

export async function fetchUserWallet(userId: string): Promise<UserWallet> {
  const wallet = await apiFetch<{
    balance: number | string;
    transactions: (WalletTransaction & { amount?: number | string })[];
  }>(`/api/v1/users/${userId}/wallet`);
  return {
    balance: Number(wallet.balance),
    transactions: wallet.transactions.map((tx) => ({
      ...tx,
      amount: Number(tx.amount),
    })),
  };
}

export async function fetchUserSupportTickets(
  userId: string,
): Promise<UserSupportTicket[]> {
  return apiFetch<UserSupportTicket[]>(`/api/v1/users/${userId}/support-tickets`);
}

export async function fetchUserActivityLogs(
  userId: string,
): Promise<UserActivityLog[]> {
  return apiFetch<UserActivityLog[]>(`/api/v1/users/${userId}/activity-logs`);
}
