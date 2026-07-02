import { authFetch } from "@/lib/api";

export interface NotificationItem {
  id: string;
  title: string;
  body: string;
  is_read: boolean;
}

export function getNotifications(page = 1, pageSize = 20): Promise<NotificationItem[]> {
  return authFetch<NotificationItem[]>(
    `/notifications?page=${page}&page_size=${pageSize}`,
    undefined,
    "Unable to load notifications"
  );
}

export function getUnreadNotificationCount(): Promise<{ count: number }> {
  return authFetch<{ count: number }>("/notifications/unread-count", undefined, "Unable to load notifications");
}

export function markNotificationRead(notificationId: string): Promise<{ message: string }> {
  return authFetch<{ message: string }>(
    `/notifications/${notificationId}/read`,
    { method: "POST" },
    "Unable to mark notification as read"
  );
}
