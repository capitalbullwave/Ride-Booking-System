import type { Metadata } from "next";
import { CorporatePortalView } from "@/components/corporate/CorporatePortalView";

export const metadata: Metadata = {
  title: "Company Portal | Bull Wave Rides",
  description: "Manage corporate employees for Bull Wave Rides for Business.",
};

export default function CorporatePortalPage() {
  return <CorporatePortalView />;
}
