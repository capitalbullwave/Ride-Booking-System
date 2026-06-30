import type { ActivityItem, ActivityTab } from "@/types/activity";

export const mockActivities: Record<ActivityTab, ActivityItem[]> = {
  Rides: [
    { id: 1, title: "Bull Wave Capital HQ", address: "124, Financial District, Downtown", date: "Today, 09:30 AM", price: "₹340", status: "Completed" },
    { id: 2, title: "Coastal Airport", address: "Terminal 2, Departures", date: "Yesterday, 06:15 PM", price: "₹850", status: "Completed" },
    { id: 3, title: "Ocean View Cafe", address: "Marine Drive, Block C", date: "12 Jun, 08:00 PM", price: "₹180", status: "Cancelled" },
  ],
  Deliveries: [
    { id: 4, title: "Package to Home", address: "Apt 4B, Sunset Boulevard", date: "10 Jun, 02:15 PM", price: "₹120", status: "Completed" },
    { id: 5, title: "Office Documents", address: "Tech Park, Building 3", date: "08 Jun, 11:00 AM", price: "₹85", status: "Completed" },
  ],
  Emergency: [
    { id: 6, title: "City General Hospital", address: "142 Medical District", date: "01 May, 03:45 AM", price: "₹1200", status: "Completed" },
  ],
};
