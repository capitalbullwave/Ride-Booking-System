"use client";

import { useRouter } from "next/navigation";
import { Ambulance, Clock, MapPin, ShieldCheck, HeartPulse, ChevronLeft, PhoneCall } from "lucide-react";

export default function AmbulanceLandingPage() {
  const router = useRouter();

  return (
    <div className="flex min-h-screen w-full flex-col bg-background pb-24 md:pb-0">
      {/* Top Header Section */}
      <div className="rounded-b-[32px] bg-[#D66B6B] px-6 pb-24 pt-12 text-white shadow-sm md:rounded-none md:pb-16 md:pt-16 md:px-12 lg:px-24">
        <div className="mx-auto flex w-full items-center justify-between">
          <button 
            onClick={() => router.back()}
            className="flex h-11 w-11 items-center justify-center rounded-full bg-white/20 transition-all hover:bg-white/30 active:scale-95 shadow-inner"
          >
            <ChevronLeft className="h-6 w-6" />
          </button>
          <h1 className="font-heading text-lg font-bold">Emergency Services</h1>
          <button className="flex h-11 w-11 items-center justify-center rounded-full bg-white text-[#D66B6B] transition-all hover:bg-white/90 active:scale-95 shadow-lg">
            <PhoneCall className="h-5 w-5" />
          </button>
        </div>
      </div>

      {/* Main Content Area */}
      <div className="mx-auto w-full flex-1 px-6 md:px-12 lg:px-24">
        {/* Hero Card */}
        <div className="-mt-16 mb-8 rounded-[24px] border border-border bg-white p-6 shadow-xl text-center flex flex-col items-center">
          <div className="mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-[#D66B6B]/10 text-[#D66B6B]">
            <Ambulance className="h-10 w-10" />
          </div>
          <h2 className="mb-2 font-heading text-2xl font-bold text-foreground">Emergency Ambulance Assistance</h2>
          <p className="mb-6 text-sm text-muted-foreground md:text-base">
            Fast, Reliable, and Professional Emergency Transportation at your fingertips.
          </p>
          <button 
            onClick={() => router.push("/ambulance/type")}
            className="w-full rounded-[16px] bg-[#D66B6B] py-4 font-bold text-white shadow-lg shadow-[#D66B6B]/30 transition-all hover:bg-[#c05959] active:scale-95 flex items-center justify-center gap-2 md:max-w-sm"
          >
            <Ambulance className="h-5 w-5" />
            REQUEST AMBULANCE NOW
          </button>
        </div>

        <h3 className="mb-4 font-heading text-lg font-bold text-foreground">Why Fast Bull Emergency?</h3>
        
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <div className="rounded-[20px] border border-border bg-white p-4 shadow-sm flex flex-col gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-secondary/20 text-[#D66B6B]">
              <Clock className="h-5 w-5" />
            </div>
            <span className="text-sm font-semibold text-foreground">24/7 Availability</span>
          </div>
          <div className="rounded-[20px] border border-border bg-white p-4 shadow-sm flex flex-col gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-secondary/20 text-[#D66B6B]">
              <MapPin className="h-5 w-5" />
            </div>
            <span className="text-sm font-semibold text-foreground">Live GPS Tracking</span>
          </div>
          <div className="rounded-[20px] border border-border bg-white p-4 shadow-sm flex flex-col gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-secondary/20 text-[#D66B6B]">
              <ShieldCheck className="h-5 w-5" />
            </div>
            <span className="text-sm font-semibold text-foreground">Certified Drivers</span>
          </div>
          <div className="rounded-[20px] border border-border bg-white p-4 shadow-sm flex flex-col gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-secondary/20 text-[#D66B6B]">
              <HeartPulse className="h-5 w-5" />
            </div>
            <span className="text-sm font-semibold text-foreground">Hospital Network</span>
          </div>
        </div>
      </div>
    </div>
  );
}
