"use client";

import { useState } from "react";
import { Send, Inbox } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { notifications } from "@/data/mock-data";
import { formatDateTime, capitalize } from "@/lib/format";
import { toast } from "sonner";
import { ROUTES } from "@/constants/routes";
import { ButtonLink } from "@/components/ui/button-link";

export default function NotificationsPage() {
  const [channels, setChannels] = useState({ push: true, sms: false, email: false });

  const handleSend = () => {
    toast.success("Notification sent successfully");
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Send Notifications"
        description="Create and send push, SMS, and email campaigns to users and drivers."
      >
        <ButtonLink variant="outline" href={ROUTES.alerts}>
          <Inbox className="mr-2 h-4 w-4" />
          Alert Inbox
        </ButtonLink>
      </PageHeader>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader><CardTitle>Create Notification</CardTitle></CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>Title</Label>
              <Input placeholder="Notification title" />
            </div>
            <div className="space-y-2">
              <Label>Message</Label>
              <Textarea placeholder="Notification message..." rows={4} />
            </div>
            <div className="space-y-2">
              <Label>Target Audience</Label>
              <Select defaultValue="all_users">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="all_users">All Users</SelectItem>
                  <SelectItem value="all_drivers">All Drivers</SelectItem>
                  <SelectItem value="specific_users">Specific Users</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Notification Type</Label>
              <Select defaultValue="promotional">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="promotional">Promotional</SelectItem>
                  <SelectItem value="ride_alert">Ride Alert</SelectItem>
                  <SelectItem value="system_alert">System Alert</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-3">
              <Label>Channels</Label>
              {(["push", "sms", "email"] as const).map((ch) => (
                <div key={ch} className="flex items-center gap-2">
                  <Checkbox
                    id={ch}
                    checked={channels[ch]}
                    onCheckedChange={(checked) =>
                      setChannels((prev) => ({ ...prev, [ch]: !!checked }))
                    }
                  />
                  <Label htmlFor={ch} className="font-normal capitalize">{ch === "push" ? "Push Notification" : ch.toUpperCase()}</Label>
                </div>
              ))}
            </div>
            <Button className="w-full" onClick={handleSend}>
              <Send className="mr-2 h-4 w-4" /> Send Notification
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Sent Notifications</CardTitle></CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Title</TableHead>
                  <TableHead>Target</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Recipients</TableHead>
                  <TableHead>Sent</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {notifications.map((n) => (
                  <TableRow key={n.id}>
                    <TableCell className="font-medium">{n.title}</TableCell>
                    <TableCell>{capitalize(n.target.replace(/_/g, " "))}</TableCell>
                    <TableCell><StatusBadge status={n.type === "promotional" ? "active" : n.type === "ride_alert" ? "busy" : "pending"} /></TableCell>
                    <TableCell>{n.recipientCount.toLocaleString()}</TableCell>
                    <TableCell>{formatDateTime(n.sentAt)}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
