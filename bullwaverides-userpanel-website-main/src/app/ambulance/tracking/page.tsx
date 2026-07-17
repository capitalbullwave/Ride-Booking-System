"use client";

import { useRouter } from "next/navigation";
import { ChevronLeft, Share2, Phone, MapPin, Navigation2 } from "lucide-react";
import { mockAssignedDriver } from "@/data/mock/ambulance";
import { useAmbulanceStore } from "@/store/useAmbulanceStore";
import Image from "next/image";

export default function LiveTrackingPage() {
  const router = useRouter();
  const { selectedHospital, patientDetails } = useAmbulanceStore();

  return (
    <div className="flex h-screen w-full flex-col bg-background relative overflow-hidden">
      
      {/* Mock Map Full Screen */}
      <div className="absolute inset-0 bg-muted/30">
        {/* We use CSS patterns to mock a map grid */}
        <div className="absolute inset-0 opacity-10" style={{ backgroundImage: "radial-gradient(#73398f 1px, transparent 1px)", backgroundSize: "20px 20px" }} />
        
        {/* Map Route Line (Mock) */}
        <div className="absolute top-[40%] left-[20%] w-[60%] h-1 bg-primary rotate-12 origin-left rounded-full shadow-[0_0_10px_rgba(49,82,110,0.5)]" />
        
        {/* Ambulance Marker */}
        <div className="absolute top-[40%] left-[20%] -translate-x-1/2 -translate-y-1/2">
          <div className="relative">
            <div className="absolute inset-0 animate-ping rounded-full bg-[#D66B6B]/40" />
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[#D66B6B] text-white shadow-xl border-4 border-white">
              <span className="text-xl">🚑</span>
            </div>
          </div>
        </div>

        {/* Destination Marker */}
        <div className="absolute top-[52%] left-[78%] -translate-x-1/2 -translate-y-1/2">
          <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary text-white shadow-xl border-2 border-white">
            <MapPin className="h-4 w-4" />
          </div>
        </div>
      </div>

      {/* Floating Header */}
      <div className="absolute top-0 left-0 right-0 z-20 p-4">
        <div className="mx-auto w-full flex items-center justify-between">
          <button 
            onClick={() => router.back()}
            className="flex h-12 w-12 items-center justify-center rounded-full bg-white shadow-md hover:bg-muted transition-colors"
          >
            <ChevronLeft className="h-6 w-6" />
          </button>
          
          <div className="rounded-full bg-white px-4 py-2 shadow-md flex items-center gap-2">
            <div className="h-2 w-2 rounded-full bg-success animate-pulse" />
            <span className="text-sm font-bold">Live Tracking</span>
          </div>

          <button className="flex h-12 w-12 items-center justify-center rounded-full bg-white shadow-md hover:bg-muted transition-colors">
            <Share2 className="h-5 w-5" />
          </button>
        </div>
      </div>

      {/* Bottom Sheet UI */}
      <div className="absolute bottom-0 left-0 right-0 z-20 bg-white rounded-t-[32px] shadow-[0_-10px_40px_rgba(0,0,0,0.1)] px-6 pt-6 pb-8 md:rounded-t-[48px] md:pb-12">
        <div className="mx-auto w-full">
          {/* Drag Handle */}
          <div className="mx-auto w-12 h-1.5 rounded-full bg-border mb-6" />
          
          <div className="flex justify-between items-end mb-6">
            <div>
              <h2 className="text-3xl font-heading font-bold text-foreground">{mockAssignedDriver.eta}</h2>
              <p className="text-sm font-semibold text-muted-foreground">1.2 km remaining</p>
            </div>
            <div className="text-right">
              <p className="text-xs font-bold text-[#D66B6B] uppercase tracking-wider">En Route to pickup</p>
            </div>
          </div>

          <div className="flex items-center justify-between mb-6 border-y border-border py-4">
            <div className="flex items-center gap-3">
              <div className="relative h-12 w-12 rounded-full bg-muted overflow-hidden">
                <Image src="/images/feature_pickup.png" alt="Driver" fill className="object-cover" />
              </div>
              <div>
                <h3 className="font-heading font-bold text-foreground text-sm">{mockAssignedDriver.name}</h3>
                <p className="text-xs font-mono font-bold text-muted-foreground">{mockAssignedDriver.vehicleNumber}</p>
              </div>
            </div>
            <div className="flex gap-2">
              <button className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 text-primary transition-colors hover:bg-primary/20">
                <Phone className="h-4 w-4" />
              </button>
            </div>
          </div>

          <div className="space-y-4">
            <div className="flex items-start gap-4">
              <div className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-[#D66B6B]/20">
                <Navigation2 className="h-3 w-3 text-[#D66B6B]" />
              </div>
              <div>
                <p className="text-[10px] font-bold text-muted-foreground uppercase">Pickup</p>
                <p className="text-sm font-semibold text-foreground line-clamp-1">{patientDetails.pickupAddress}</p>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <div className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary/20">
                <MapPin className="h-3 w-3 text-primary" />
              </div>
              <div>
                <p className="text-[10px] font-bold text-muted-foreground uppercase">Destination</p>
                <p className="text-sm font-semibold text-foreground line-clamp-1">{selectedHospital?.name}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>
  );
}
