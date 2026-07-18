import { apiFetch, authFetch } from "@/lib/api";
import { triggerRideSos } from "@/lib/ride-api";

export interface FaqItem {
  category: string;
  question: string;
  answer: string;
}

export interface SupportTicketMessage {
  id?: string;
  sender?: string;
  message: string;
  created_at?: string;
}

export interface SupportTicket {
  id: string;
  subject: string;
  status: string;
  created_at?: string;
  updated_at?: string;
  messages?: SupportTicketMessage[];
}

export function getFaqs(): Promise<FaqItem[]> {
  return apiFetch<FaqItem[]>("/api/v1/common/support/faqs", undefined, "Unable to load FAQs");
}

export function createSupportTicket(payload: {
  subject: string;
  message: string;
  category?: string;
}): Promise<SupportTicket> {
  return authFetch<SupportTicket>(
    "/support",
    {
      method: "POST",
      body: JSON.stringify({
        subject: payload.subject,
        message: payload.message,
        category: payload.category,
      }),
    },
    "Unable to create support ticket"
  );
}

export function getSupportTickets(): Promise<SupportTicket[]> {
  return authFetch<{ data?: SupportTicket[] } | SupportTicket[]>(
    "/support/tickets",
    undefined,
    "Unable to load tickets"
  ).then((res) => (Array.isArray(res) ? res : res.data ?? []));
}

export function getSupportTicket(ticketId: string): Promise<SupportTicket> {
  return authFetch<SupportTicket>(
    `/support/tickets/${ticketId}`,
    undefined,
    "Unable to load ticket"
  );
}

/** Prefer ride-scoped SOS so admin/driver get the same alerts as the app. */
export function triggerSos(payload: {
  ride_id?: string;
  latitude?: number;
  longitude?: number;
  message?: string;
}) {
  if (!payload.ride_id) {
    return Promise.reject(new Error("SOS requires an active ride"));
  }
  return triggerRideSos(payload.ride_id, {
    lat: payload.latitude,
    lng: payload.longitude,
    message: payload.message,
  });
}
