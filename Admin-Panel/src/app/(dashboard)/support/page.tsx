"use client";

import { useEffect, useMemo, useState } from "react";
import { Eye } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatusBadge } from "@/components/shared/status-badge";
import { ButtonLink } from "@/components/ui/button-link";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { SupportTicket } from "@/types";
import { formatDateTime, capitalize } from "@/lib/format";
import { fetchSupportTickets } from "@/lib/support-api";

export default function SupportPage() {
  const [tab, setTab] = useState("all");
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const data = await fetchSupportTickets();
        if (!cancelled) setTickets(data);
      } catch {
        if (!cancelled) setTickets([]);
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const filtered = useMemo(() => {
    return tickets.filter((t) => {
      if (tab === "user") return t.userType === "user";
      if (tab === "driver") return t.userType === "driver";
      if (tab === "open") return t.status === "open" || t.status === "in_progress";
      if (tab === "closed") return t.status === "resolved" || t.status === "closed";
      return true;
    });
  }, [tickets, tab]);

  return (
    <div className="space-y-6">
      <PageHeader title="Support Center" description="Manage user and driver support tickets" />

      <div className="grid gap-4 sm:grid-cols-4">
        {[
          { label: "Open Tickets", value: tickets.filter((t) => t.status === "open").length, color: "text-blue-600" },
          { label: "In Progress", value: tickets.filter((t) => t.status === "in_progress").length, color: "text-amber-600" },
          { label: "Resolved", value: tickets.filter((t) => t.status === "resolved").length, color: "text-emerald-600" },
          { label: "Closed", value: tickets.filter((t) => t.status === "closed").length, color: "text-slate-600" },
        ].map((stat) => (
          <Card key={stat.label}>
            <CardContent className="p-6 text-center">
              <p className={`text-3xl font-bold ${stat.color}`}>{stat.value}</p>
              <p className="text-sm text-muted-foreground">{stat.label}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="all">All Tickets</TabsTrigger>
          <TabsTrigger value="user">User Tickets</TabsTrigger>
          <TabsTrigger value="driver">Driver Tickets</TabsTrigger>
          <TabsTrigger value="open">Open</TabsTrigger>
          <TabsTrigger value="closed">Closed</TabsTrigger>
        </TabsList>
        <TabsContent value={tab} className="mt-6">
          <Card>
            <CardContent className="p-0">
              {loading ? (
                <p className="p-8 text-center text-sm text-muted-foreground">Loading tickets…</p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Ticket ID</TableHead>
                      <TableHead>Subject</TableHead>
                      <TableHead>User</TableHead>
                      <TableHead>Type</TableHead>
                      <TableHead>Priority</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Updated</TableHead>
                      <TableHead>Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filtered.map((ticket) => (
                      <TableRow key={ticket.id}>
                        <TableCell className="font-mono text-xs">{ticket.id.slice(0, 8)}…</TableCell>
                        <TableCell className="font-medium">{ticket.subject}</TableCell>
                        <TableCell>{ticket.userName}</TableCell>
                        <TableCell>{capitalize(ticket.userType)}</TableCell>
                        <TableCell><StatusBadge status={ticket.priority} /></TableCell>
                        <TableCell><StatusBadge status={ticket.status} /></TableCell>
                        <TableCell>{formatDateTime(ticket.updatedAt)}</TableCell>
                        <TableCell>
                          <ButtonLink variant="ghost" size="icon" href={`/support/${ticket.id}`}>
                            <Eye className="h-4 w-4" />
                          </ButtonLink>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
