import { apiFetch, authFetch } from "@/lib/api";

export interface FaqItem {
  category: string;
  question: string;
  answer: string;
}

export interface SupportTicket {
  id: string;
  subject: string;
  status: string;
}

export function getFaqs(): Promise<FaqItem[]> {
  return apiFetch<FaqItem[]>("/api/v1/common/support/faqs", undefined, "Unable to load FAQs");
}

export function createSupportTicket(payload: { subject: string; message: string }): Promise<SupportTicket> {
  return authFetch<SupportTicket>(
    "/support/tickets",
    { method: "POST", body: JSON.stringify(payload) },
    "Unable to create support ticket"
  );
}

export function getSupportTickets(): Promise<SupportTicket[]> {
  return authFetch<SupportTicket[]>("/support/tickets", undefined, "Unable to load tickets");
}

export function triggerSos(payload: {
  ride_id?: string;
  latitude?: number;
  longitude?: number;
}): Promise<{ id: string; status: string }> {
  return authFetch<{ id: string; status: string }>(
    "/emergency/sos",
    { method: "POST", body: JSON.stringify(payload) },
    "Unable to send SOS"
  );
}
