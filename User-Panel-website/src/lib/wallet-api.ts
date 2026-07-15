import { authFetch } from "@/lib/api";

export interface WalletBalance {
  balance: number;
  bonus_balance: number;
  referral_balance: number;
  total: number;
  has_bank_account?: boolean;
  bank?: {
    account_holder: string;
    account_number: string;
    ifsc: string;
    bank_name: string;
    upi_id?: string | null;
  } | null;
}

export interface WalletSummary extends WalletBalance {
  cashback_total?: number;
  referral_earned?: number;
}

export interface WalletTransaction {
  amount: number;
  type: "credit" | "debit";
  description: string;
  at: string;
}

export interface PaymentMethod {
  id: string;
  type: string;
  label: string;
  last_four: string | null;
}

interface BackendTransaction {
  amount: number;
  transaction_type: string;
  description: string;
  created_at: string;
}

export function getWalletBalance(): Promise<WalletBalance> {
  return authFetch<WalletBalance>("/wallet", undefined, "Unable to load wallet");
}

export function getWalletSummary(): Promise<WalletSummary> {
  return authFetch<WalletSummary>("/wallet", undefined, "Unable to load wallet summary");
}

export function getWalletTransactions(page = 1, pageSize = 20): Promise<WalletTransaction[]> {
  return authFetch<BackendTransaction[]>(
    `/transactions?page=${page}&page_size=${pageSize}`,
    undefined,
    "Unable to load transactions"
  ).then((items) =>
    items.map((t) => ({
      amount: t.amount,
      type: t.transaction_type.toLowerCase() === "credit" ? "credit" : "debit",
      description: t.description,
      at: t.created_at,
    }))
  );
}

export function saveWalletBank(payload: {
  payment_type: "bank" | "upi";
  account_holder_name: string;
  account_number?: string;
  ifsc_code?: string;
  bank_name?: string;
  upi_id?: string;
}) {
  return authFetch(
    "/wallet/bank",
    { method: "POST", body: JSON.stringify(payload) },
    "Unable to save bank account"
  );
}

export function requestWalletWithdraw(amount: number) {
  return authFetch<{ id: string; status: string; message: string }>(
    "/wallet/withdraw",
    { method: "POST", body: JSON.stringify({ amount }) },
    "Unable to request withdrawal"
  );
}

export function addWalletMoney(amount: number): Promise<WalletBalance> {
  return authFetch<{ balance: number }>(
    "/payment",
    { method: "POST", body: JSON.stringify({ amount }) },
    "Unable to add money"
  ).then((res) => ({
    balance: res.balance,
    bonus_balance: 0,
    referral_balance: 0,
    total: res.balance,
  }));
}

export function getPaymentMethods(): Promise<PaymentMethod[]> {
  return Promise.resolve([
    { id: "cash", type: "cash", label: "Cash", last_four: null },
    { id: "wallet", type: "wallet", label: "Wallet", last_four: null },
  ]);
}
