"use client";

import { useRouter } from "next/navigation";
import { Phone, Navigation, ShieldCheck, MapPin, Ambulance } from "lucide-react";
import { mockAssignedDriver } from "@/data/mock/ambulance";
import { useAmbulanceStore } from "@/store/useAmbulanceStore";
import Image from "next/image";

export default function AssignedAmbulancePage() {
  const router = useRouter();
  const { selectedType, selectedHospital } = useAmbulanceStore();

  return (
    <div className="flex min-h-screen w-full flex-col bg-background pb-32">
      {/* Map Placeholder Header */}
      <div className="relative h-64 w-full bg-muted/50 overflow-hidden">
        {/* Mock Map Background */}
        <div className="absolute inset-0 opacity-20 bg-[url('https://maps.gstatic.com/mapfiles/api-3/images/cb_scout5.png')] bg-repeat" />
        <div className="absolute inset-0 bg-gradient-to-b from-transparent to-background/90" />
        
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="relative">
            <div className="absolute inset-0 animate-ping rounded-full bg-[#D66B6B]/20" />
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[#D66B6B] text-white shadow-lg">
              <Ambulance className="h-6 w-6" />
            </div>
          </div>
        </div>
      </div>

      {/* Main Content (Pulls up over map) */}
      <div className="mx-auto w-full flex-1 px-4 -mt-12 relative z-10">
        
        <div className="mb-4 text-center">
          <h2 className="text-2xl font-heading font-bold text-foreground">Ambulance Assigned</h2>
          <p className="text-sm font-semibold text-[#D66B6B]">Arriving in {mockAssignedDriver.eta}</p>
        </div>

        <div className="md:grid md:grid-cols-2 md:gap-4">
          {/* Driver Card */}
          <div className="rounded-[24px] border border-border bg-white p-5 shadow-lg mb-4 md:mb-0">
            <div className="flex items-center justify-between mb-4 border-b border-border pb-4">
              <div className="flex items-center gap-3">
                <div className="relative h-14 w-14 rounded-full bg-muted overflow-hidden">
                  <Image src="/images/feature_pickup.png" alt="Driver" fill className="object-cover" />
                </div>
                <div>
                  <h3 className="font-heading font-bold text-foreground">{mockAssignedDriver.name}</h3>
                  <div className="flex items-center gap-1 text-xs font-semibold text-warning">
                    ★ {mockAssignedDriver.rating} <span className="text-muted-foreground ml-1">Certified Medic</span>
                  </div>
                </div>
              </div>
              <div className="text-right">
                <div className="rounded-md bg-muted px-2 py-1 text-sm font-bold tracking-wider font-mono">
                  {mockAssignedDriver.vehicleNumber}
                </div>
                <p className="text-[10px] text-muted-foreground mt-1">{selectedType?.name}</p>
              </div>
            </div>

            <div className="flex gap-3">
              <button className="flex flex-1 items-center justify-center gap-2 rounded-[16px] bg-[#D66B6B]/10 py-3 font-semibold text-[#D66B6B] transition-colors hover:bg-[#D66B6B]/20">
                <Phone className="h-4 w-4" /> Call Driver
              </button>
              <button className="flex flex-1 items-center justify-center gap-2 rounded-[16px] bg-primary/10 py-3 font-semibold text-primary transition-colors hover:bg-primary/20">
                <ShieldCheck className="h-4 w-4" /> Support
              </button>
            </div>
          </div>

          {/* Route Card */}
          <div className="rounded-[20px] border border-border bg-white p-5 shadow-sm h-fit">
            <div className="flex items-center gap-3 mb-2">
              <MapPin className="h-5 w-5 text-[#D66B6B]" />
              <span className="text-sm font-bold text-foreground">Destination</span>
            </div>
            <p className="text-sm font-semibold ml-8">{selectedHospital?.name}</p>
            <p className="text-xs text-muted-foreground ml-8">{selectedHospital?.address}</p>
          </div>
        </div>
      </div>

      {/* Bottom Sticky Action */}
      <div className="fixed bottom-0 left-0 right-0 border-t border-border bg-white p-6 shadow-[0_-10px_20px_rgba(0,0,0,0.05)] z-20">
        <div className="mx-auto w-full">
          <button
            onClick={() => router.push("/ambulance/tracking")}
            className="w-full rounded-[16px] bg-[#D66B6B] py-4 font-bold text-white shadow-lg transition-all hover:bg-[#c05959] active:scale-95 flex items-center justify-center gap-2"
          >
            <Navigation className="h-5 w-5" />
            OPEN LIVE TRACKING
          </button>
        </div>
      </div>

    </div>
  );
}
