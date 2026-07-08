import type { AppNotification } from "@/types/notification";

export const mockNotifications: AppNotification[] = [
  {
    id: "1",
    type: "ride",
    title: "Driver is on the way",
    message: "Rajesh is arriving in 4 minutes. Track your ride from the app.",
    time: "2 min ago",
    read: false,
  },
  {
    id: "2",
    type: "payment",
    title: "Payment successful",
    message: "₹142 was charged to your Bull Wave Rides Wallet for your last ride.",
    time: "1 hour ago",
    read: false,
  },
  {
    id: "3",
    type: "promo",
    title: "20% off your next ride",
    message: "Use code WAVE20 on your next booking. Valid until Sunday.",
    time: "Yesterday",
    read: true,
  },
  {
    id: "4",
    type: "ambulance",
    title: "Ambulance booking confirmed",
    message: "Your emergency request has been assigned. ETA 8 minutes.",
    time: "2 days ago",
    read: true,
  },
  {
    id: "5",
    type: "ride",
    title: "Trip completed",
    message: "Your ride to Connaught Place was completed. Rate your driver.",
    time: "3 days ago",
    read: true,
  },
  {
    id: "6",
    type: "system",
    title: "Profile updated",
    message: "Your phone number was successfully verified.",
    time: "1 week ago",
    read: true,
  },
];
