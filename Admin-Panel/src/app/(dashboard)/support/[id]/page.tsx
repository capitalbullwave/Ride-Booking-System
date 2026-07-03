"use client";

import { notFound } from "next/navigation";
import { use, useEffect, useState } from "react";
import { ArrowLeft, Send, Paperclip } from "lucide-react";
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
            <CardHeader><CardTitle>Chat Thread</CardTitle></CardHeader>
            <CardContent className="space-y-4">
              {ticket.messages.map((msg) => (
                <div
                  key={msg.id}
                  className={`rounded-lg p-4 ${
                    msg.senderType === "admin"
                      ? "ml-8 bg-primary/5 border border-primary/20"
                      : "mr-8 bg-muted"
                  }`}
                >
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-sm font-medium">{msg.sender}</span>
                    <span className="text-xs text-muted-foreground">
                      {formatDateTime(msg.timestamp)}
                    </span>
                  </div>
                  <p className="text-sm">{msg.message}</p>
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
          <Card>
            <CardHeader><CardTitle>Ticket Details</CardTitle></CardHeader>
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
                  <span className="text-sm font-medium text-right break-all">{value}</span>
                </div>
              ))}
            </CardContent>
          </Card>

          <Card>
            <CardHeader><CardTitle>Status Update</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              <Select value={status} onValueChange={(v) => setStatus(v as TicketStatus)}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="open">Open</SelectItem>
                  <SelectItem value="in_progress">In Progress</SelectItem>
                  <SelectItem value="resolved">Resolved</SelectItem>
                  <SelectItem value="closed">Closed</SelectItem>
                </SelectContent>
              </Select>
              <Button className="w-full" onClick={handleStatusUpdate}>
                Update Status
              </Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader><CardTitle>Internal Notes</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              <Textarea
                placeholder="Add internal note (not visible to user)..."
                value={internalNote}
                onChange={(e) => setInternalNote(e.target.value)}
                rows={3}
              />
              <Button variant="outline" className="w-full" disabled>
                Save Note
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
