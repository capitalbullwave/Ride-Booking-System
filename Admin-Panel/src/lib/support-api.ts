import { apiFetch } from "@/lib/api";
import type { SupportTicket, TicketStatus } from "@/types";

export async function fetchSupportTickets(): Promise<SupportTicket[]> {
  const res = await apiFetch<SupportTicket[]>("/api/v1/admin/support/tickets");
  return Array.isArray(res) ? res : [];
}

export async function fetchSupportTicket(id: string): Promise<SupportTicket> {
  return apiFetch<SupportTicket>(`/api/v1/admin/support/tickets/${id}`);
}

export async function replySupportTicket(
  id: string,
  message: string,
): Promise<SupportTicket> {
  return apiFetch<SupportTicket>(`/api/v1/admin/support/tickets/${id}/reply`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ message }),
  });
}

export async function updateSupportTicketStatus(
  id: string,
  status: TicketStatus,
): Promise<SupportTicket> {
  return apiFetch<SupportTicket>(`/api/v1/admin/support/tickets/${id}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status }),
  });
}
