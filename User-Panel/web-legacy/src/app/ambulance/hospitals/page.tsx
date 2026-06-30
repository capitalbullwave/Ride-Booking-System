"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ChevronLeft, Search, SlidersHorizontal } from "lucide-react";
import { useAmbulanceStore } from "@/store/useAmbulanceStore";
import { mockHospitals } from "@/data/mock/ambulance";
import { HospitalCard } from "@/components/ambulance/HospitalCard";
import type { Hospital } from "@/types/ambulance";

export default function HospitalSelectionPage() {
  const router = useRouter();
  const { setHospital } = useAmbulanceStore();
  const [searchQuery, setSearchQuery] = useState("");
  const [filter, setFilter] = useState("All");

  const filters = ["All", "Nearest", "ER Available", "ICU", "Government"];

  const handleSelectHospital = (hospital: Hospital) => {
    setHospital(hospital);
    router.push("/ambulance/form");
  };

  const filteredHospitals = mockHospitals.filter(h => {
    if (searchQuery && !h.name.toLowerCase().includes(searchQuery.toLowerCase())) return false;
    if (filter === "ER Available" && !h.emergencyAvailable) return false;
    if (filter === "ICU" && !h.icuAvailable) return false;
    if (filter === "Government" && h.type !== "Government") return false;
    return true;
  });

  return (
    <div className="flex min-h-screen w-full flex-col bg-background pb-24 md:pb-0">
      {/* Top Header */}
      <div className="sticky top-0 z-10 border-b border-border bg-white px-4 pt-4 pb-2">
        <div className="flex items-center mb-4">
          <button 
            onClick={() => router.back()}
            className="flex h-10 w-10 items-center justify-center rounded-full hover:bg-muted transition-colors"
          >
            <ChevronLeft className="h-6 w-6" />
          </button>
          <h1 className="ml-2 font-heading text-lg font-bold">Select Destination Hospital</h1>
        </div>

        {/* Search & Filter */}
        <div className="flex items-center gap-2 mb-3">
          <div className="flex flex-1 items-center gap-2 rounded-[14px] bg-muted/50 px-3 py-2 border border-border focus-within:border-primary focus-within:bg-white transition-colors">
            <Search className="h-4 w-4 text-muted-foreground" />
            <input 
              type="text" 
              placeholder="Search hospitals..." 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-transparent text-sm outline-none"
            />
          </div>
          <button className="flex h-10 w-10 shrink-0 items-center justify-center rounded-[14px] border border-border bg-white text-foreground hover:bg-muted">
            <SlidersHorizontal className="h-4 w-4" />
          </button>
        </div>

        {/* Filter Pills */}
        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
          {filters.map(f => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`shrink-0 rounded-full px-4 py-1.5 text-xs font-semibold transition-all ${
                filter === f ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:bg-muted/80"
              }`}
            >
              {f}
            </button>
          ))}
        </div>
      </div>

      {/* Main Content */}
      <div className="mx-auto w-full flex-1 px-4 py-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredHospitals.map((hospital) => (
            <HospitalCard
              key={hospital.id}
              hospital={hospital}
              onSelect={handleSelectHospital}
            />
          ))}
          {filteredHospitals.length === 0 && (
            <div className="py-12 text-center text-muted-foreground col-span-full">
              No hospitals found matching your criteria.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
