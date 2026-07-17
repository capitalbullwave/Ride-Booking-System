export type NotificationType = "ride" | "promo" | "payment" | "ambulance" | "system";

export interface AppNotification {
  id: string;
  type: NotificationType;
  title: string;
  message: string;
  time: string;
  read: boolean;
}
