"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import {
  Bell,
  Car,
  MapPin,
  HeadphonesIcon,
  FileText,
  Wallet,
  Server,
  CheckCheck,
  ExternalLink,
} from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { adminAlerts as fallbackAlerts } from "@/data/mock-data";
import { AdminAlert, AdminAlertType } from "@/types";
import { ROUTES } from "@/constants/routes";
import { formatDateTime } from "@/lib/format";
import { fetchAdminAlerts } from "@/lib/alerts-api";
import { cn } from "@/lib/utils";
import { toast } from "sonner";

const alertIcons: Record<AdminAlertType, typeof Bell> = {
  driver_registration: Car,
  ride_update: MapPin,
  support_ticket: HeadphonesIcon,
  report: FileText,
  payment: Wallet,
  system: Server,
};

const alertColors: Record<AdminAlertType, string> = {
  driver_registration: "bg-primary/10 text-primary",
  ride_update: "bg-success/15 text-success",
  support_ticket: "bg-warning/15 text-warning",
  report: "bg-secondary/25 text-secondary-foreground",
  payment: "bg-muted text-muted-foreground",
  system: "bg-muted text-muted-foreground",
};

export default function AlertsInboxPage() {
  const [alerts, setAlerts] = useState<AdminAlert[]>([]);
  const [loading, setLoading] = useState(true);
  const [tab, setTab] = useState("all");

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const data = await fetchAdminAlerts();
        if (!cancelled) setAlerts(data.length > 0 ? data : fallbackAlerts);
      } catch {
        if (!cancelled) setAlerts(fallbackAlerts);
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const unreadCount = alerts.filter((a) => a.unread).length;

  const filtered = useMemo(() => {
    if (tab === "unread") return alerts.filter((a) => a.unread);
    if (tab === "read") return alerts.filter((a) => !a.unread);
    return alerts;
  }, [alerts, tab]);

  const markAsRead = (id: string) => {
    setAlerts((prev) => prev.map((a) => (a.id === id ? { ...a, unread: false } : a)));
  };

  const markAllRead = () => {
    setAlerts((prev) => prev.map((a) => ({ ...a, unread: false })));
    toast.success("All alerts marked as read");
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Alert Inbox"
        description="Platform alerts for your admin account — driver signups, rides, tickets, and system updates."
      >
        <ButtonLink variant="outline" href={ROUTES.notifications}>
          <ExternalLink className="mr-2 h-4 w-4" />
          Send Notifications
        </ButtonLink>
        {unreadCount > 0 && (
          <Button variant="outline" onClick={markAllRead}>
            <CheckCheck className="mr-2 h-4 w-4" />
            Mark all read
          </Button>
        )}
      </PageHeader>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardContent className="p-5">
            <p className="text-sm text-muted-foreground">Unread</p>
            <p className="font-heading text-3xl font-bold text-primary">{unreadCount}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-5">
            <p className="text-sm text-muted-foreground">Total alerts</p>
            <p className="font-heading text-3xl font-bold">{alerts.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-5">
            <p className="text-sm text-muted-foreground">Today</p>
            <p className="font-heading text-3xl font-bold">
              {alerts.filter((a) => a.time.includes("min") || a.time.includes("hour")).length}
            </p>
          </CardContent>
        </Card>
      </div>

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="all">All</TabsTrigger>
          <TabsTrigger value="unread">Unread ({unreadCount})</TabsTrigger>
          <TabsTrigger value="read">Read</TabsTrigger>
        </TabsList>
        <TabsContent value={tab} className="mt-6 space-y-3">
          {loading ? (
            <Card>
              <CardContent className="flex flex-col items-center justify-center py-16 text-center">
                <p className="text-sm text-muted-foreground">Loading alerts…</p>
              </CardContent>
            </Card>
          ) : filtered.length === 0 ? (
            <Card>
              <CardContent className="flex flex-col items-center justify-center py-16 text-center">
                <Bell className="mb-4 h-10 w-10 text-muted-foreground/50" />
                <p className="font-medium">No alerts here</p>
                <p className="mt-1 text-sm text-muted-foreground">You&apos;re all caught up.</p>
              </CardContent>
            </Card>
          ) : (
            filtered.map((alert) => {
              const Icon = alertIcons[alert.type];
              const content = (
                <div
                  className={cn(
                    "flex gap-4 rounded-[1.25rem] border p-4 transition-colors",
                    alert.unread
                      ? "border-primary/20 bg-primary/5 wavego-card-shadow"
                      : "border-border/80 bg-card hover:bg-muted/30"
                  )}
                >
                  <div className={cn("flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl", alertColors[alert.type])}>
                    <Icon className="h-5 w-5" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex flex-wrap items-center gap-2">
                      {alert.unread && (
                        <span className="h-2 w-2 shrink-0 rounded-full bg-primary" />
                      )}
                      <p className="font-medium">{alert.title}</p>
                      {alert.unread && <StatusBadge status="open" />}
                    </div>
                    <p className="mt-1 text-sm text-muted-foreground">{alert.message}</p>
                    <p className="mt-2 text-xs text-muted-foreground">
                      {alert.time} · {formatDateTime(alert.createdAt)}
                    </p>
                  </div>
                  <div className="flex shrink-0 flex-col gap-2">
                    {alert.unread && (
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={(e) => {
                          e.preventDefault();
                          e.stopPropagation();
                          markAsRead(alert.id);
                        }}
                      >
                        Mark read
                      </Button>
                    )}
                  </div>
                </div>
              );

              if (alert.href) {
                return (
                  <Link
                    key={alert.id}
                    href={alert.href}
                    onClick={() => markAsRead(alert.id)}
                    className="block"
                  >
                    {content}
                  </Link>
                );
              }

              return <div key={alert.id}>{content}</div>;
            })
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}
