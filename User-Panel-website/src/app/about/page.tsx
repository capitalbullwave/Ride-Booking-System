import type { Metadata } from "next";
import { AboutUsView } from "@/components/landing/AboutUsView";

export const metadata: Metadata = {
  title: "About Us | Bull Wave Rides",
  description:
    "Learn about Bull Wave Rides — India's mobility platform for rides, parcels, and emergency ambulance SOS, built for riders and captains.",
};

export default function AboutPage() {
  return <AboutUsView />;
}
