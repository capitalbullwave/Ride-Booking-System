import { apiFetch } from "@/lib/api";

export type FinanceTransaction = {
  id: string;
  type: string;
  description: string;
  amount: number;
  status: string;
  date: string;
  userId?: string;
  driverId?: string;
  rideId?: string;
  paymentMethod?: string;
};

export async function fetchFinanceTransactions(params?: {
  type?: string;
  page?: number;
  limit?: number;
}): Promise<{ items: FinanceTransaction[]; total: number }> {
  const query = new URLSearchParams();
  if (params?.type && params.type !== "all") query.set("type", params.type);
  if (params?.page) query.set("page", String(params.page));
  if (params?.limit) query.set("limit", String(params.limit));
  const qs = query.toString();
  const res = await apiFetch<{ items: unknown[]; total: number }>(
    `/api/v1/admin/finance/transactions${qs ? `?${qs}` : ""}`,
  );

  return {
    total: Number(res.total ?? 0),
    items: (Array.isArray(res.items) ? res.items : []).map((raw) => {
      const t = (raw ?? {}) as Record<string, unknown>;
      return {
        id: String(t.id ?? ""),
        type: String(t.type ?? ""),
        description: String(t.description ?? ""),
        amount: Number(t.amount ?? 0),
        status: String(t.status ?? "completed"),
        date: String(t.date ?? t.createdAt ?? new Date().toISOString()),
        userId: t.userId != null ? String(t.userId) : undefined,
        driverId: t.driverId != null ? String(t.driverId) : undefined,
        rideId: t.rideId != null ? String(t.rideId) : undefined,
        paymentMethod: t.paymentMethod != null ? String(t.paymentMethod) : undefined,
      };
    }),
  };
}

