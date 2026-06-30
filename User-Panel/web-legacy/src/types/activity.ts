export interface ActivityItem {
  id: number;
  title: string;
  address: string;
  date: string;
  price: string;
  status: string;
}

export type ActivityTab = "Rides" | "Deliveries" | "Emergency";
