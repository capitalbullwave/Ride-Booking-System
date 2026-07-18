"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Loader2 } from "lucide-react";
import { HelpTopicShell } from "@/components/profile/help/HelpTopicShell";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/constants/routes";
import {
  createSupportTicket,
  getSupportTicket,
  getSupportTickets,
  type SupportTicket,
} from "@/lib/support-api";

export function HelpMessagesView() {
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [selected, setSelected] = useState<SupportTicket | null>(null);
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState<string | null>(null);

  const loadTickets = async () => {
    setLoading(true);
    try {
      const rows = await getSupportTickets();
      setTickets(rows);
    } catch {
      setTickets([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void loadTickets();
  }, []);

  const openTicket = async (ticketId: string) => {
    try {
      const detail = await getSupportTicket(ticketId);
      setSelected(detail);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to load ticket");
    }
  };

  const handleCreate = async () => {
    if (!subject.trim() || !message.trim()) return;
    setCreating(true);
    setError(null);
    try {
      const ticket = await createSupportTicket({
        subject: subject.trim(),
        message: message.trim(),
      });
      setSubject("");
      setMessage("");
      await loadTickets();
      await openTicket(ticket.id);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to create ticket");
    } finally {
      setCreating(false);
    }
  };

  const openTickets = tickets.filter((t) =>
    ["open", "in_progress", "pending"].includes((t.status || "").toLowerCase())
  );
  const archivedTickets = tickets.filter(
    (t) => !["open", "in_progress", "pending"].includes((t.status || "").toLowerCase())
  );

  return (
    <HelpTopicShell title="Support messages" variant="light">
      <div className="max-w-3xl">
        {selected ? (
          <section className="mb-8">
            <button
              type="button"
              onClick={() => setSelected(null)}
              className="mb-3 text-sm font-semibold text-primary"
            >
              ← Back to tickets
            </button>
            <div className="rounded-[18px] border border-border bg-card p-4">
              <p className="text-sm font-semibold text-primary">{selected.status}</p>
              <h2 className="mt-1 font-heading text-lg font-bold">{selected.subject}</h2>
              <div className="mt-4 space-y-3">
                {(selected.messages ?? []).length === 0 ? (
                  <p className="text-sm text-muted-foreground">No messages yet.</p>
                ) : (
                  (selected.messages ?? []).map((msg, index) => (
                    <div
                      key={msg.id || index}
                      className="rounded-xl bg-muted/40 px-3 py-2 text-sm"
                    >
                      <p className="font-semibold text-foreground">
                        {msg.sender || "Support"}
                      </p>
                      <p className="mt-1 text-muted-foreground">{msg.message}</p>
                    </div>
                  ))
                )}
              </div>
            </div>
          </section>
        ) : (
          <>
            <section className="mb-8 rounded-[18px] border border-border bg-card p-4">
              <h2 className="mb-3 font-heading text-sm font-bold uppercase tracking-wide text-muted-foreground">
                New ticket
              </h2>
              <input
                value={subject}
                onChange={(e) => setSubject(e.target.value)}
                placeholder="Subject"
                className="mb-2 h-11 w-full rounded-xl border border-border bg-background px-3 text-sm outline-none focus:border-primary"
              />
              <textarea
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder="Describe your issue"
                rows={3}
                className="mb-3 w-full rounded-xl border border-border bg-background px-3 py-2 text-sm outline-none focus:border-primary"
              />
              {error ? <p className="mb-2 text-sm text-destructive">{error}</p> : null}
              <Button
                disabled={creating || !subject.trim() || !message.trim()}
                onClick={() => void handleCreate()}
              >
                {creating ? <Loader2 className="h-4 w-4 animate-spin" /> : "Submit ticket"}
              </Button>
            </section>

            {loading ? (
              <div className="flex justify-center py-10">
                <Loader2 className="h-6 w-6 animate-spin text-primary" />
              </div>
            ) : (
              <>
                <section className="mb-8">
                  <h2 className="mb-3 font-heading text-sm font-bold uppercase tracking-wide text-muted-foreground">
                    Open
                  </h2>
                  {openTickets.length === 0 ? (
                    <p className="text-sm text-muted-foreground">No open tickets</p>
                  ) : (
                    <div className="space-y-2">
                      {openTickets.map((ticket) => (
                        <button
                          key={ticket.id}
                          type="button"
                          onClick={() => void openTicket(ticket.id)}
                          className="w-full rounded-[18px] border border-primary/20 bg-primary/[0.04] p-4 text-left transition-colors hover:border-primary/30"
                        >
                          <div className="flex items-center justify-between gap-3">
                            <span className="text-sm font-semibold text-primary">
                              {ticket.status}
                            </span>
                            <span className="text-xs text-muted-foreground">
                              {ticket.created_at
                                ? new Date(ticket.created_at).toLocaleString("en-IN")
                                : ""}
                            </span>
                          </div>
                          <p className="mt-2 text-sm font-medium text-foreground">
                            {ticket.subject}
                          </p>
                        </button>
                      ))}
                    </div>
                  )}
                </section>

                <section>
                  <h2 className="mb-3 font-heading text-sm font-bold uppercase tracking-wide text-muted-foreground">
                    Archive
                  </h2>
                  {archivedTickets.length === 0 ? (
                    <p className="text-sm text-muted-foreground">No archived tickets</p>
                  ) : (
                    <div className="divide-y divide-border overflow-hidden rounded-[18px] border border-border bg-card">
                      {archivedTickets.map((ticket) => (
                        <button
                          key={ticket.id}
                          type="button"
                          onClick={() => void openTicket(ticket.id)}
                          className="w-full px-4 py-4 text-left transition-colors hover:bg-muted/40"
                        >
                          <p className="text-sm font-medium text-foreground">{ticket.subject}</p>
                          <div className="mt-2 flex items-center justify-between gap-3">
                            <span className="text-xs font-medium text-muted-foreground">
                              {ticket.status}
                            </span>
                            <span className="text-xs text-muted-foreground">
                              {ticket.created_at
                                ? new Date(ticket.created_at).toLocaleString("en-IN")
                                : ""}
                            </span>
                          </div>
                        </button>
                      ))}
                    </div>
                  )}
                </section>
              </>
            )}
          </>
        )}

        <p className="mt-6 text-sm text-muted-foreground">
          Need new help?{" "}
          <Link href={ROUTES.profileHelp} className="font-semibold text-primary hover:underline">
            Browse all topics
          </Link>
        </p>
      </div>
    </HelpTopicShell>
  );
}
