import { helpSectionPath } from "@/lib/help-routes";

export interface SupportTrip {
  id: number;
  service: string;
  address: string;
  date: string;
  status: string;
  price: string;
}

export const supportTrips: SupportTrip[] = [
  {
    id: 1,
    service: "Bike",
    address: "F6, Okhala Estate Marg,...",
    date: "Apr 22",
    status: "Canceled",
    price: "₹0.00",
  },
  {
    id: 2,
    service: "Electric Auto | Bajaj RE 4S",
    address: "F6, Okhala Estate Marg,...",
    date: "Apr 12",
    status: "Completed",
    price: "₹62.58",
  },
  {
    id: 3,
    service: "Cab",
    address: "Bull Wave Capital HQ",
    date: "Mar 28",
    status: "Completed",
    price: "₹340.00",
  },
];

export interface HelpTopic {
  id: string;
  label: string;
  route: string;
}

export const helpTopics: HelpTopic[] = [
  { id: "safety", label: "Safety & emergency", route: helpSectionPath("safety-emergency") },
  { id: "trip", label: "Help with a trip", route: helpSectionPath("trip") },
  { id: "account", label: "Account", route: helpSectionPath("account") },
  { id: "membership", label: "Membership", route: helpSectionPath("membership") },
  { id: "accessibility", label: "Accessibility", route: helpSectionPath("accessibility") },
  { id: "grievance", label: "Grievance redressal", route: helpSectionPath("grievance") },
  { id: "guides", label: "Guides", route: helpSectionPath("guides") },
  { id: "transit", label: "Bus, Metro, and Train", route: helpSectionPath("transit") },
  { id: "cancellation", label: "Cancellation policy", route: helpSectionPath("cancellation") },
  { id: "map", label: "Map issue", route: helpSectionPath("map") },
  { id: "passes", label: "Ride Passes", route: helpSectionPath("passes") },
];
