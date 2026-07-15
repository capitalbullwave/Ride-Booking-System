"use client";

import { notFound } from "next/navigation";
import { use, useEffect, useMemo, useState } from "react";
import { ArrowLeft, ExternalLink, MapPin, Navigation, Paperclip, Send } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Separator } from "@/components/ui/separator";
import { SupportTicket, TicketStatus } from "@/types";
import { formatDateTime, capitalize } from "@/lib/format";
import {
  fetchSupportTicket,
  replySupportTicket,
  updateSupportTicketStatus,
} from "@/lib/support-api";
import { toast } from "sonner";

const MAPS_URL_RE = /https?:\/\/(?:www\.)?google\.com\/maps[^\s]+/gi;

function extractLabeledMapLinks(text: string) {
  const currentMatch = text.match(/Current location:\s*(https?:\/\/[^\s]+)/i);
  const liveMatch = text.match(/Live location:\s*(https?:\/\/[^\s]+)/i);
  const anyLinks = text.match(MAPS_URL_RE) ?? [];
  return {
    current: currentMatch?.[1] ?? null,
    live: liveMatch?.[1] ?? (anyLinks.length > 0 ? anyLinks[anyLinks.length - 1] : null),
  };
}

function MessageWithLinks({ text }: { text: string }) {
  const parts = text.split(/(https?:\/\/[^\s]+)/g);
  return (
    <p className="whitespace-pre-wrap text-sm leading-relaxed">
      {parts.map((part, index) =>
        /^https?:\/\//i.test(part) ? (
          <a
            key={`${part}-${index}`}
            href={part}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1 break-all font-medium text-primary underline underline-offset-2"
          >
            {part}
            <ExternalLink className="h-3 w-3 shrink-0" />
          </a>
        ) : (
          <span key={`${index}-${part.slice(0, 12)}`}>{part}</span>
        )
      )}
    </p>
  );
}

export default function TicketDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const [ticket, setTicket] = useState<SupportTicket | null>(null);
  const [loading, setLoading] = useState(true);
  const [reply, setReply] = useState("");
  const [sending, setSending] = useState(false);
  const [status, setStatus] = useState<TicketStatus>("open");
  const [internalNote, setInternalNote] = useState("");

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const data = await fetchSupportTicket(id);
        if (!cancelled) {
          setTicket(data);
          setStatus(data.status);
        }
      } catch {
        if (!cancelled) setTicket(null);
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [id]);

  const locationLinks = useMemo(() => {
    if (!ticket) return { current: null, live: null };
    const source = [ticket.description, ...(ticket.messages?.map((m) => m.message) ?? [])]
      .filter(Boolean)
      .join("\n");
    return extractLabeledMapLinks(source);
  }, [ticket]);

  if (loading) {
    return (
      <div className="flex min-h-[40vh] items-center justify-center text-muted-foreground">
        Loading ticket…
      </div>
    );
  }

  if (!ticket) notFound();

  const handleReply = async () => {
    const text = reply.trim();
    if (!text) return;
    setSending(true);
    try {
      const updated = await replySupportTicket(id, text);
      setTicket(updated);
      setReply("");
      toast.success("Reply sent to user");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to send reply");
    } finally {
      setSending(false);
    }
  };

  const handleStatusUpdate = async () => {
    try {
      const updated = await updateSupportTicketStatus(id, status);
      setTicket(updated);
      toast.success("Status updated");
    } catch {
      toast.error("Failed to update status");
    }
  };

  const isSosTicket =
    ticket.subject.toLowerCase().includes("sos") ||
    Boolean(locationLinks.current || locationLinks.live);

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <ButtonLink variant="ghost" size="icon" href="/support">
          <ArrowLeft className="h-4 w-4" />
        </ButtonLink>
        <PageHeader title={ticket.subject} description={`Ticket ${ticket.id}`}>
          <StatusBadge status={ticket.status} />
          <StatusBadge status={ticket.priority} />
        </PageHeader>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Chat Thread</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {ticket.messages.map((msg) => (
                <div
                  key={msg.id}
                  className={`rounded-lg p-4 ${
                    msg.senderType === "admin"
                      ? "ml-8 border border-primary/20 bg-primary/5"
                      : "mr-8 bg-muted"
                  }`}
                >
                  <div className="mb-2 flex items-center justify-between">
                    <span className="text-sm font-medium">{msg.sender}</span>
                    <span className="text-xs text-muted-foreground">
                      {formatDateTime(msg.timestamp)}
                    </span>
                  </div>
                  <MessageWithLinks text={msg.message} />
                </div>
              ))}

              <Separator />

              <div className="space-y-3">
                <Textarea
                  placeholder="Type your reply..."
                  value={reply}
                  onChange={(e) => setReply(e.target.value)}
                  rows={3}
                />
                <div className="flex items-center justify-between">
                  <Button variant="outline" size="sm" disabled>
                    <Paperclip className="mr-2 h-4 w-4" /> Attach
                  </Button>
                  <Button onClick={handleReply} disabled={!reply.trim() || sending}>
                    <Send className="mr-2 h-4 w-4" /> Send Reply
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="space-y-6">
          {isSosTicket && (locationLinks.current || locationLinks.live) ? (
            <Card className="border-destructive/30 bg-destructive/5">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-destructive">
                  <MapPin className="h-4 w-4" />
                  Track Locations
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <p className="text-xs text-muted-foreground">
                  Open Google Maps to track passenger current location and captain live location.
                </p>
                {locationLinks.current ? (
                  <a
                    href={locationLinks.current}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center justify-between rounded-lg border border-border bg-card px-3 py-2.5 text-sm font-semibold text-foreground transition-colors hover:bg-muted"
                  >
                    <span className="inline-flex items-center gap-2">
                      <MapPin className="h-4 w-4 text-primary" />
                      Current location
                    </span>
                    <ExternalLink className="h-4 w-4 text-muted-foreground" />
                  </a>
                ) : null}
                {locationLinks.live ? (
                  <a
                    href={locationLinks.live}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center justify-between rounded-lg border border-border bg-card px-3 py-2.5 text-sm font-semibold text-foreground transition-colors hover:bg-muted"
                  >
                    <span className="inline-flex items-center gap-2">
                      <Navigation className="h-4 w-4 text-destructive" />
                      Live location
                    </span>
                    <ExternalLink className="h-4 w-4 text-muted-foreground" />
                  </a>
                ) : null}
              </CardContent>
            </Card>
          ) : null}

          <Card>
            <CardHeader>
              <CardTitle>Ticket Details</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {[
                ["Ticket ID", ticket.id],
                ["User", ticket.userName],
                ["Type", capitalize(ticket.userType)],
                ["Priority", capitalize(ticket.priority)],
                ["Created", formatDateTime(ticket.createdAt)],
                ["Updated", formatDateTime(ticket.updatedAt)],
              ].map(([label, value]) => (
                <div key={label} className="flex justify-between gap-4">
                  <span className="text-sm text-muted-foreground">{label}</span>
                  <span className="break-all text-right text-sm font-medium">{value}</span>
                </div>
              ))}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Status Update</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <Select value={status} onValueChange={(v) => setStatus(v as TicketStatus)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="open">open</SelectItem>
                  <SelectItem value="in_progress">in_progress</SelectItem>
                  <SelectItem value="resolved">resolved</SelectItem>
                  <SelectItem value="closed">closed</SelectItem>
                </SelectContent>
              </Select>
              <Button className="w-full" onClick={handleStatusUpdate}>
                Update Status
              </Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Internal Notes</CardTitle>
            </CardHeader>
            <CardContent>
              <Textarea
                placeholder="Add internal notes (not visible to user)..."
                value={internalNote}
                onChange={(e) => setInternalNote(e.target.value)}
                rows={4}
              />
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
