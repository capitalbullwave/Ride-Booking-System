import type { Metadata } from "next";
import { CorporateRegisterView } from "@/components/corporate/CorporateRegisterView";

export const metadata: Metadata = {
  title: "Corporate Registration | Bull Wave Rides",
  description:
    "Register your company for Bull Wave Rides for Business. Employees book rides billed to your company after admin approval.",
};

export default function CorporateRegisterPage() {
  return <CorporateRegisterView />;
}
