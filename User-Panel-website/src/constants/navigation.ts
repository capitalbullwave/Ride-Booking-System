import { CalendarCheck, Home, User, Wallet } from "lucide-react";
import { ROUTES } from "./routes";

export const bottomNavItems = [
  { icon: Home, label: "Home", href: ROUTES.home },
  { icon: CalendarCheck, label: "Bookings", href: ROUTES.bookings },
  { icon: Wallet, label: "Wallet", href: ROUTES.wallet },
  { icon: User, label: "Profile", href: ROUTES.profile },
] as const;
