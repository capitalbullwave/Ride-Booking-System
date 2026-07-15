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

export type FinanceOverview = {
  totalRevenue: number;
  platformCommission: number;
  driverEarnings: number;
  pendingPayouts: number;
  pendingPayoutCount: number;
  pendingApprovalsCount: number;
  pendingWithdrawalRequests: number;
  pendingRefundRequests: number;
  revenueChange: string;
  revenueChangeType: "positive" | "negative" | "neutral";
  platformFeePercent: number;
  driverSharePercent: number;
  thisMonthRevenue: number;
  thisMonthCommission: number;
};

export type FinanceActivity = {
  id: string;
  party: "user" | "driver" | string;
  category: string;
  type: string;
  title: string;
  amount: number;
  status: string;
  date: string;
  partyName: string;
  partyId?: string;
  reference?: string;
  actionable?: boolean;
};

export type FinancePayout = {
  id: string;
  party?: "user" | "driver" | string;
  driverId?: string | null;
  userId?: string | null;
  driverPublicId?: string;
  userPublicId?: string;
  driverName?: string | null;
  userName?: string | null;
  partyName?: string;
  partyId?: string;
  partyPublicId?: string;
  amount: number;
  status: string;
  date: string;
  createdAt?: string;
  processedAt?: string | null;
  method: string;
  rejectionReason?: string | null;
  bankDetails?: {
    accountHolder?: string;
    accountNumber?: string;
    ifsc?: string;
    bankName?: string;
    upiId?: string;
  } | null;
};

export type FinanceRefund = {
  id: string;
  rideId: string;
  user: string;
  amount: number;
  reason: string;
  status: string;
  date: string;
  source?: string;
  paymentMethod?: string;
};

export type FinanceApprovals = {
  payouts: FinancePayout[];
  refunds: FinanceRefund[];
  history: FinancePayout[];
  paidCount: number;
  rejectedCount: number;
  pendingPayouts: number;
  pendingRefunds: number;
  totalPending: number;
};

export type CommissionReport = {
  totalCommissionYtd: number;
  commissionRate: number;
  thisMonthCommission: number;
  months: Array<{
    month: string;
    year: number;
    revenue: number;
    commission: number;
    rides: number;
  }>;
};

function mapPayout(raw: unknown): FinancePayout {
  const p = (raw ?? {}) as Record<string, unknown>;
  const party = String(p.party ?? (p.userId ? "user" : "driver"));
  const partyName =
    String(p.partyName ?? p.userName ?? p.driverName ?? (party === "user" ? "User" : "Driver"));
  const bankRaw = p.bankDetails;
  let bankDetails: FinancePayout["bankDetails"] = null;
  if (bankRaw && typeof bankRaw === "object") {
    const b = bankRaw as Record<string, unknown>;
    bankDetails = {
      accountHolder: b.accountHolder != null ? String(b.accountHolder) : undefined,
      accountNumber: b.accountNumber != null ? String(b.accountNumber) : undefined,
      ifsc: b.ifsc != null ? String(b.ifsc) : undefined,
      bankName: b.bankName != null ? String(b.bankName) : undefined,
      upiId: b.upiId != null ? String(b.upiId) : undefined,
    };
  }
  return {
    id: String(p.id ?? ""),
    party,
    driverId: p.driverId != null ? String(p.driverId) : null,
    userId: p.userId != null ? String(p.userId) : null,
    driverPublicId: p.driverPublicId != null ? String(p.driverPublicId) : undefined,
    userPublicId: p.userPublicId != null ? String(p.userPublicId) : undefined,
    driverName: p.driverName != null ? String(p.driverName) : null,
    userName: p.userName != null ? String(p.userName) : null,
    partyName,
    partyId: p.partyId != null ? String(p.partyId) : undefined,
    partyPublicId: p.partyPublicId != null ? String(p.partyPublicId) : undefined,
    amount: Number(p.amount ?? 0),
    status: String(p.status ?? "pending"),
    date: String(p.date ?? p.createdAt ?? ""),
    createdAt: p.createdAt != null ? String(p.createdAt) : undefined,
    processedAt: p.processedAt != null ? String(p.processedAt) : null,
    method: String(p.method ?? "Bank Transfer"),
    rejectionReason: p.rejectionReason != null ? String(p.rejectionReason) : null,
    bankDetails,
  };
}

function mapRefund(raw: unknown): FinanceRefund {
  const r = (raw ?? {}) as Record<string, unknown>;
  return {
    id: String(r.id ?? ""),
    rideId: String(r.rideId ?? "—"),
    user: String(r.user ?? "—"),
    amount: Number(r.amount ?? 0),
    reason: String(r.reason ?? ""),
    status: String(r.status ?? "completed"),
    date: String(r.date ?? ""),
    source: r.source != null ? String(r.source) : undefined,
    paymentMethod: r.paymentMethod != null ? String(r.paymentMethod) : undefined,
  };
}

export async function fetchFinanceOverview(): Promise<FinanceOverview> {
  const res = await apiFetch<Record<string, unknown>>("/api/v1/admin/finance/overview");
  return {
    totalRevenue: Number(res.totalRevenue ?? 0),
    platformCommission: Number(res.platformCommission ?? 0),
    driverEarnings: Number(res.driverEarnings ?? 0),
    pendingPayouts: Number(res.pendingPayouts ?? 0),
    pendingPayoutCount: Number(res.pendingPayoutCount ?? 0),
    pendingApprovalsCount: Number(res.pendingApprovalsCount ?? 0),
    pendingWithdrawalRequests: Number(res.pendingWithdrawalRequests ?? 0),
    pendingRefundRequests: Number(res.pendingRefundRequests ?? 0),
    revenueChange: String(res.revenueChange ?? ""),
    revenueChangeType: String(res.revenueChangeType ?? "neutral") as FinanceOverview["revenueChangeType"],
    platformFeePercent: Number(res.platformFeePercent ?? 0),
    driverSharePercent: Number(res.driverSharePercent ?? 0),
    thisMonthRevenue: Number(res.thisMonthRevenue ?? 0),
    thisMonthCommission: Number(res.thisMonthCommission ?? 0),
  };
}

export async function fetchFinanceActivity(params?: {
  party?: string;
  category?: string;
  page?: number;
  limit?: number;
}): Promise<{ items: FinanceActivity[]; total: number }> {
  const query = new URLSearchParams();
  if (params?.party && params.party !== "all") query.set("party", params.party);
  if (params?.category && params.category !== "all") query.set("category", params.category);
  if (params?.page) query.set("page", String(params.page));
  if (params?.limit) query.set("limit", String(params.limit ?? 100));
  const qs = query.toString();
  const res = await apiFetch<{ items: unknown[]; total: number }>(
    `/api/v1/admin/finance/activity${qs ? `?${qs}` : ""}`,
  );
  return {
    total: Number(res.total ?? 0),
    items: (Array.isArray(res.items) ? res.items : []).map((raw) => {
      const a = (raw ?? {}) as Record<string, unknown>;
      return {
        id: String(a.id ?? ""),
        party: String(a.party ?? ""),
        category: String(a.category ?? ""),
        type: String(a.type ?? ""),
        title: String(a.title ?? ""),
        amount: Number(a.amount ?? 0),
        status: String(a.status ?? ""),
        date: String(a.date ?? ""),
        partyName: String(a.partyName ?? "—"),
        partyId: a.partyId != null ? String(a.partyId) : undefined,
        reference: a.reference != null ? String(a.reference) : undefined,
        actionable: Boolean(a.actionable),
      };
    }),
  };
}

/** @deprecated use fetchFinanceActivity */
export async function fetchFinanceTransactions(params?: {
  type?: string;
  page?: number;
  limit?: number;
}): Promise<{ items: FinanceTransaction[]; total: number }> {
  const res = await fetchFinanceActivity({
    page: params?.page,
    limit: params?.limit,
    category: params?.type && params.type !== "all" ? params.type : "all",
  });
  return {
    total: res.total,
    items: res.items.map((a) => ({
      id: a.id,
      type: a.type,
      description: a.title,
      amount: a.amount,
      status: a.status,
      date: a.date,
      userId: a.party === "user" ? a.partyId : undefined,
      driverId: a.party === "driver" ? a.partyId : undefined,
      rideId: a.reference,
    })),
  };
}

export async function fetchFinanceApprovals(): Promise<FinanceApprovals> {
  const res = await apiFetch<Record<string, unknown>>("/api/v1/admin/finance/approvals");
  return {
    payouts: (Array.isArray(res.payouts) ? res.payouts : []).map(mapPayout),
    refunds: (Array.isArray(res.refunds) ? res.refunds : []).map(mapRefund),
    history: (Array.isArray(res.history) ? res.history : []).map(mapPayout),
    paidCount: Number(res.paidCount ?? 0),
    rejectedCount: Number(res.rejectedCount ?? 0),
    pendingPayouts: Number(res.pendingPayouts ?? 0),
    pendingRefunds: Number(res.pendingRefunds ?? 0),
    totalPending: Number(res.totalPending ?? 0),
  };
}

export async function fetchFinancePayouts(params?: {
  status?: string;
  page?: number;
  limit?: number;
}): Promise<{ items: FinancePayout[]; total: number }> {
  const query = new URLSearchParams();
  if (params?.status && params.status !== "all") query.set("status", params.status);
  if (params?.page) query.set("page", String(params.page));
  if (params?.limit) query.set("limit", String(params.limit ?? 100));
  const qs = query.toString();
  const res = await apiFetch<{ items: unknown[]; total: number }>(
    `/api/v1/admin/finance/payouts${qs ? `?${qs}` : ""}`,
  );
  return {
    total: Number(res.total ?? 0),
    items: (Array.isArray(res.items) ? res.items : []).map(mapPayout),
  };
}

export async function processFinancePayout(id: string): Promise<void> {
  await apiFetch(`/api/v1/admin/finance/payouts/${id}/process`, { method: "POST" });
}

export async function rejectFinancePayout(id: string, reason?: string): Promise<void> {
  await apiFetch(`/api/v1/admin/finance/payouts/${id}/reject`, {
    method: "POST",
    body: JSON.stringify({ reason: reason ?? null }),
  });
}

export async function processAllFinancePayouts(): Promise<{ processed: number; failed: number }> {
  const res = await apiFetch<{ processed: number; failed: number }>(
    "/api/v1/admin/finance/payouts/process-all",
    { method: "POST" },
  );
  return { processed: Number(res.processed ?? 0), failed: Number(res.failed ?? 0) };
}

export async function approveFinanceRefund(paymentId: string): Promise<void> {
  await apiFetch(`/api/v1/admin/finance/refunds/${paymentId}/approve`, { method: "POST" });
}

export async function rejectFinanceRefund(paymentId: string, reason?: string): Promise<void> {
  await apiFetch(`/api/v1/admin/finance/refunds/${paymentId}/reject`, {
    method: "POST",
    body: JSON.stringify({ reason: reason ?? null }),
  });
}

export async function fetchFinanceRefunds(params?: {
  page?: number;
  limit?: number;
}): Promise<{ items: FinanceRefund[]; total: number }> {
  const query = new URLSearchParams();
  if (params?.page) query.set("page", String(params.page));
  if (params?.limit) query.set("limit", String(params.limit ?? 100));
  const qs = query.toString();
  const res = await apiFetch<{ items: unknown[]; total: number }>(
    `/api/v1/admin/finance/refunds${qs ? `?${qs}` : ""}`,
  );
  return {
    total: Number(res.total ?? 0),
    items: (Array.isArray(res.items) ? res.items : []).map(mapRefund),
  };
}

export async function fetchCommissionReport(): Promise<CommissionReport> {
  const res = await apiFetch<Record<string, unknown>>("/api/v1/admin/finance/commission-report");
  const monthsRaw = Array.isArray(res.months) ? res.months : [];
  return {
    totalCommissionYtd: Number(res.totalCommissionYtd ?? 0),
    commissionRate: Number(res.commissionRate ?? 0),
    thisMonthCommission: Number(res.thisMonthCommission ?? 0),
    months: monthsRaw.map((raw) => {
      const m = (raw ?? {}) as Record<string, unknown>;
      return {
        month: String(m.month ?? ""),
        year: Number(m.year ?? 0),
        revenue: Number(m.revenue ?? 0),
        commission: Number(m.commission ?? 0),
        rides: Number(m.rides ?? 0),
      };
    }),
  };
}
