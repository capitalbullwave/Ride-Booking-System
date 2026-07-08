import type { Metadata } from "next";
import { SafetyPolicyView } from "@/components/landing/SafetyPolicyView";

export const metadata: Metadata = {
  title: "Safety | Bull Wave Rides",
  description:
    "Bull Wave Rides safety for riders and drivers — verified profiles, live tracking, SOS emergency assistance, 24×7 support, and community ratings.",
};

export default function SafetyPage() {
  return <SafetyPolicyView />;
}
