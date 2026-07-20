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
  Gift,
  ScanFace,
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
      { title: "Drivers", href: "/drivers", icon: Car },
      { title: "Selfie Verification", href: "/selfie-verifications", icon: ScanFace },
      { title: "Rides", href: "/rides", icon: MapPin },
      { title: "Vehicles", href: "/vehicles", icon: Truck },
    ],
  },
  {
    title: "Business",
    items: [
      { title: "Finance", href: "/finance", icon: Wallet },
      { title: "Subscriptions", href: "/subscriptions", icon: Crown },
      { title: "Coupons", href: "/coupons", icon: Ticket },
      { title: "Refer & Earn", href: "/refer-earn", icon: Gift },
      { title: "Support", href: "/support", icon: HeadphonesIcon },
      { title: "Alert Inbox", href: "/alerts", icon: Inbox },
      { title: "Send Notifications", href: "/notifications", icon: Bell },
    ],
  },
  {
    title: "Insights",
    items: [
      { title: "Reports", href: "/reports", icon: BarChart3 },
      { title: "App Settings", href: "/settings", icon: Settings },
      { title: "Driver Commission", href: "/settings/driver-commission", icon: Settings },
    ],
  },
];

export const financeSubNav: NavItem[] = [
  { title: "Overview", href: "/finance", icon: Wallet },
  { title: "All Activity", href: "/finance/activity", icon: Wallet },
  { title: "Approvals & Payments", href: "/finance/approvals", icon: Wallet },
  { title: "Commission", href: "/finance/commission", icon: Wallet },
];
