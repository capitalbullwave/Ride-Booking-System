"use client";

import Link from "next/link";
import {
  UserPlus,
  Bell,
  FileText,
  Ticket,
  MapPin,
  UserCheck,
  Car,
  Navigation,
  Loader2,
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { StatusBadge } from "@/components/shared/status-badge";
import { cn } from "@/lib/utils";
import { capitalize, formatNumber } from "@/lib/format";
import type { OnlineDriverItem } from "@/lib/dashboard-api";
import type { ActivityItem } from "@/types";

const activityIcons = {
  ride_request: MapPin,
  registration: UserPlus,
  driver_online: Car,
  ongoing_ride: Navigation,
};

const activityColors = {
  ride_request: "bg-primary/10 text-primary",
  registration: "bg-success/15 text-success",
  driver_online: "bg-warning/15 text-warning",
  ongoing_ride: "bg-secondary/25 text-secondary-foreground",
};

type LiveActivityProps = {
  activities: ActivityItem[];
  isLoading?: boolean;
};

export function LiveActivity({ activities, isLoading = false }: LiveActivityProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>Live Activity</CardTitle>
        <ButtonLink href="/rides" variant="ghost" size="sm">
          View All
        </ButtonLink>
      </CardHeader>
      <CardContent className="space-y-4">
        {isLoading ? (
          <div className="flex items-center justify-center py-10 text-sm text-muted-foreground">
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            Loading activity...
          </div>
        ) : activities.length === 0 ? (
          <p className="py-10 text-center text-sm text-muted-foreground">
            No recent activity yet
          </p>
        ) : (
          activities.map((activity) => {
            const Icon = activityIcons[activity.type];
            return (
              <div key={activity.id} className="flex items-start gap-3">
                <div className={cn("rounded-2xl p-2.5", activityColors[activity.type])}>
                  <Icon className="h-4 w-4" />
                </div>
                <div className="flex-1 space-y-1">
                  <div className="flex items-center justify-between gap-2">
                    <p className="text-sm font-medium">{activity.title}</p>
                    {activity.status ? <StatusBadge status={activity.status} /> : null}
                  </div>
                  <p className="text-xs text-muted-foreground">{activity.description}</p>
                  <p className="text-xs text-muted-foreground">{activity.timestamp}</p>
                </div>
              </div>
            );
          })
        )}
      </CardContent>
    </Card>
  );
}

const quickActions = [
  { label: "Add Driver", href: "/drivers", icon: UserPlus, color: "bg-primary/10 text-primary" },
  { label: "Send Notification", href: "/notifications", icon: Bell, color: "bg-secondary/10 text-secondary" },
  { label: "View Reports", href: "/reports", icon: FileText, color: "bg-accent/20 text-accent-foreground" },
  { label: "Create Coupon", href: "/coupons", icon: Ticket, color: "bg-muted text-muted-foreground" },
];

export function QuickActions() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Quick Actions</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-2 gap-3">
          {quickActions.map((action) => (
            <Link key={action.href} href={action.href}>
              <Button
                variant="outline"
                className="h-auto w-full flex-col gap-2 rounded-[1.25rem] py-4 hover:border-primary/40 hover:bg-primary/5"
              >
                <div className={cn("rounded-2xl p-2.5", action.color)}>
                  <action.icon className="h-5 w-5" />
                </div>
                <span className="text-xs font-medium">{action.label}</span>
              </Button>
            </Link>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}

type OnlineDriversCardProps = {
  drivers: OnlineDriverItem[];
  activeCount: number;
  isLoading?: boolean;
};

export function OnlineDriversCard({
  drivers,
  activeCount,
  isLoading = false,
}: OnlineDriversCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="flex items-center gap-2">
          <UserCheck className="h-5 w-5 text-success" />
          Online Drivers
        </CardTitle>
        <span className="text-sm font-medium text-success">
          {isLoading ? "—" : `${formatNumber(activeCount)} active`}
        </span>
      </CardHeader>
      <CardContent className="space-y-3">
        {isLoading ? (
          <div className="flex items-center justify-center py-8 text-sm text-muted-foreground">
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            Loading drivers...
          </div>
        ) : drivers.length === 0 ? (
          <p className="py-8 text-center text-sm text-muted-foreground">
            No drivers online right now
          </p>
        ) : (
          drivers.map((driver) => (
            <div
              key={driver.id}
              className="flex items-center justify-between rounded-2xl border border-border/80 bg-muted/30 p-3"
            >
              <div>
                <p className="text-sm font-medium">{driver.name}</p>
                <p className="text-xs text-muted-foreground">
                  {capitalize(driver.vehicleType.replace(/_/g, " "))} · {capitalize(driver.status)}
                </p>
              </div>
              <span className="h-2 w-2 rounded-full bg-success shadow-sm shadow-success/50" />
            </div>
          ))
        )}
      </CardContent>
    </Card>
  );
}
