import { Banknote, ScanLine } from "lucide-react";

export const paymentMethods = [
  {
    id: "cash",
    title: "Cash",
    description: "Pay your driver directly after the ride",
    badge: "Preferred",
    icon: Banknote,
    variant: "cash" as const,
  },
  {
    id: "upi",
    title: "UPI Scan and Pay",
    description: "Quick payments with any UPI app",
    badge: null,
    icon: ScanLine,
    variant: "upi" as const,
  },
] as const;
