"use client";

import { useRouter } from "next/navigation";
import { ChevronLeft } from "lucide-react";
import { useAmbulanceStore } from "@/store/useAmbulanceStore";
import { mockAmbulanceTypes } from "@/data/mock/ambulance";
import { AmbulanceCard } from "@/components/ambulance/AmbulanceCard";

export default function AmbulanceTypePage() {
  const router = useRouter();
  const { selectedType, setType } = useAmbulanceStore();

  const handleContinue = () => {
    if (selectedType) {
      router.push("/ambulance/hospitals");
    }
  };

  return (
    <div className="flex min-h-screen w-full flex-col bg-background">
      {/* Top Header */}
      <div className="sticky top-0 z-10 flex h-16 items-center border-b border-border bg-white px-4">
        <button 
          onClick={() => router.back()}
          className="flex h-10 w-10 items-center justify-center rounded-full hover:bg-muted transition-colors"
        >
          <ChevronLeft className="h-6 w-6" />
        </button>
        <h1 className="ml-2 font-heading text-lg font-bold">Select Ambulance Type</h1>
      </div>

      {/* Main Content */}
      <div className="mx-auto w-full flex-1 px-6 py-6 pb-32">
        <p className="mb-6 text-sm text-muted-foreground">
          Choose the appropriate ambulance type based on the emergency severity.
        </p>

        <div className="flex flex-col gap-4">
          {mockAmbulanceTypes.map((type) => (
            <AmbulanceCard
              key={type.id}
              type={type}
              isSelected={selectedType?.id === type.id}
              onSelect={setType}
            />
          ))}
        </div>
      </div>

      {/* Bottom Sticky Action */}
      <div className="fixed bottom-0 left-0 right-0 border-t border-border bg-white p-6 shadow-[0_-10px_20px_rgba(0,0,0,0.05)]">
        <div className="mx-auto w-full">
          <button
            onClick={handleContinue}
            disabled={!selectedType}
            className="w-full rounded-[16px] bg-[#D66B6B] py-4 font-bold text-white shadow-lg transition-all hover:bg-[#c05959] active:scale-95 disabled:opacity-50 disabled:pointer-events-none"
          >
            Continue to Hospital Selection
          </button>
        </div>
      </div>
    </div>
  );
}
