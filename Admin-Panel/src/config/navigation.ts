import {
  LayoutDashboard,
  Users,
  Car,
  MapPin,
  Truck,
  Wallet,
  Ticket,
  HeadphonesIcon,
  Bell,
  Inbox,
  BarChart3,
  Settings,
  GraduationCap,
  Crown,
  type LucideIcon,
} from "lucide-react";

export interface NavItem {
  title: string;
  href: string;
  icon: LucideIcon;
  badge?: string;
}

export interface NavGroup {
  title: string;
  items: NavItem[];
}

export const navigation: NavGroup[] = [
  {
    title: "Overview",
    items: [
      { title: "Dashboard", href: "/", icon: LayoutDashboard },
    ],
  },
  {
    title: "Management",
    items: [
      { title: "Users", href: "/users", icon: Users },
      { title: "Student Passes", href: "/student-passes", icon: GraduationCap },
      { title: "Drivers", href: "/drivers", icon: Car, badge: "12" },
      { title: "Rides", href: "/rides", icon: MapPin, badge: "892" },
      { title: "Vehicles", href: "/vehicles", icon: Truck },
    ],
  },
  {
    title: "Business",
    items: [
      { title: "Finance", href: "/finance", icon: Wallet },
      { title: "Subscriptions", href: "/subscriptions", icon: Crown },
      { title: "Coupons", href: "/coupons", icon: Ticket },
      { title: "Support", href: "/support", icon: HeadphonesIcon, badge: "3" },
      { title: "Alert Inbox", href: "/alerts", icon: Inbox, badge: "3" },
      { title: "Send Notifications", href: "/notifications", icon: Bell },
    ],
  },
  {
    title: "Insights",
    items: [
      { title: "Reports", href: "/reports", icon: BarChart3 },
      { title: "App Settings", href: "/settings", icon: Settings },
    ],
  },
];

export const financeSubNav: NavItem[] = [
  { title: "Overview", href: "/finance", icon: Wallet },
  { title: "Transactions", href: "/finance/transactions", icon: Wallet },
  { title: "Driver Payouts", href: "/finance/payouts", icon: Wallet },
  { title: "Refund Requests", href: "/finance/refunds", icon: Wallet },
  { title: "Wallet", href: "/finance/wallet", icon: Wallet },
  { title: "Commission", href: "/finance/commission", icon: Wallet },
];
