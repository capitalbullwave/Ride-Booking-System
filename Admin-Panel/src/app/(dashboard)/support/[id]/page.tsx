"use client";

import { notFound } from "next/navigation";
import { use, useState } from "react";
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
import { getTicketById } from "@/data/mock-data";
import { formatDateTime, capitalize } from "@/lib/format";
import { toast } from "sonner";

export default function TicketDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const ticket = getTicketById(id);
  const [reply, setReply] = useState("");
  const [internalNote, setInternalNote] = useState("");

  if (!ticket) notFound();

  const handleReply = () => {
    toast.success("Reply sent successfully");
    setReply("");
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
                  <Button variant="outline" size="sm">
                    <Paperclip className="mr-2 h-4 w-4" /> Attach
                  </Button>
                  <Button onClick={handleReply} disabled={!reply.trim()}>
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
                <div key={label} className="flex justify-between">
                  <span className="text-sm text-muted-foreground">{label}</span>
                  <span className="text-sm font-medium">{value}</span>
                </div>
              ))}
            </CardContent>
          </Card>

          <Card>
            <CardHeader><CardTitle>Status Update</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              <Select defaultValue={ticket.status}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="open">Open</SelectItem>
                  <SelectItem value="in_progress">In Progress</SelectItem>
                  <SelectItem value="resolved">Resolved</SelectItem>
                  <SelectItem value="closed">Closed</SelectItem>
                </SelectContent>
              </Select>
              <Button className="w-full">Update Status</Button>
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
              <Button variant="outline" className="w-full">Save Note</Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
