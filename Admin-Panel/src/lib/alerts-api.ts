import { apiFetch } from "@/lib/api";
import type { AdminAlert } from "@/types";

export async function fetchAdminAlerts(): Promise<AdminAlert[]> {
  const res = await apiFetch<AdminAlert[]>("/api/v1/admin/alerts");
  return Array.isArray(res) ? res : [];
}
