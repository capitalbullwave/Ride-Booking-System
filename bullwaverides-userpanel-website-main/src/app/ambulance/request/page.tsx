"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ChevronLeft, AlertTriangle, Info, Clock, IndianRupee, Ambulance } from "lucide-react";
import { useAmbulanceStore } from "@/store/useAmbulanceStore";

export default function RequestAmbulancePage() {
  const router = useRouter();
  const { selectedType, selectedHospital, patientDetails } = useAmbulanceStore();
  const [showModal, setShowModal] = useState(false);

  const handleConfirm = () => {
    setShowModal(false);
    router.push("/ambulance/searching");
  };

  return (
    <div className="flex min-h-screen w-full flex-col bg-background pb-32">
      {/* Top Header */}
      <div className="sticky top-0 z-10 flex h-16 items-center border-b border-border bg-white px-4 shadow-sm">
        <button 
          onClick={() => router.back()}
          className="flex h-10 w-10 items-center justify-center rounded-full hover:bg-muted transition-colors"
        >
          <ChevronLeft className="h-6 w-6" />
        </button>
        <h1 className="ml-2 font-heading text-lg font-bold">Review Request</h1>
      </div>

      {/* Main Content */}
      <div className="mx-auto w-full flex-1 px-4 py-6 flex flex-col gap-4">
        
        {/* Route Summary */}
        <div className="rounded-[20px] border border-border bg-white p-5 shadow-sm relative">
          <div className="absolute left-[31px] top-[46px] bottom-[46px] w-[2px] bg-border border-dashed" />
          
          <div className="flex items-start gap-4 mb-6">
            <div className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary/20 z-10">
              <div className="h-2 w-2 rounded-full bg-primary" />
            </div>
            <div>
              <p className="text-[10px] font-bold text-muted-foreground uppercase">Pickup Location</p>
              <p className="text-sm font-semibold text-foreground">{patientDetails.pickupAddress}</p>
            </div>
          </div>

          <div className="flex items-start gap-4">
            <div className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-[#D66B6B]/20 z-10">
              <div className="h-2 w-2 rounded-full bg-[#D66B6B]" />
            </div>
            <div>
              <p className="text-[10px] font-bold text-muted-foreground uppercase">Destination Hospital</p>
              <p className="text-sm font-semibold text-[#D66B6B]">{selectedHospital?.name || "Not Selected"}</p>
              <p className="text-xs text-muted-foreground">{selectedHospital?.address}</p>
            </div>
          </div>
        </div>

        <div className="md:grid md:grid-cols-2 md:gap-4">
          {/* Patient Info */}
          <div className="rounded-[20px] border border-border bg-white p-5 shadow-sm">
            <h3 className="text-sm font-bold text-foreground mb-3 border-b border-border pb-2">Patient Details</h3>
            <div className="grid grid-cols-2 gap-y-3 gap-x-4">
              <div>
                <p className="text-[10px] text-muted-foreground">Name</p>
                <p className="text-sm font-semibold">{patientDetails.patientName}</p>
              </div>
              <div>
                <p className="text-[10px] text-muted-foreground">Age</p>
                <p className="text-sm font-semibold">{patientDetails.patientAge}</p>
              </div>
              <div>
                <p className="text-[10px] text-muted-foreground">Emergency Type</p>
                <p className="text-sm font-semibold text-[#D66B6B]">{patientDetails.emergencyType}</p>
              </div>
              <div>
                <p className="text-[10px] text-muted-foreground">Contact</p>
                <p className="text-sm font-semibold">{patientDetails.emergencyContact}</p>
              </div>
            </div>
          </div>

          {/* Service Details */}
          <div className="rounded-[20px] border border-border bg-white p-5 shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-bold text-foreground">Service Details</h3>
              <span className="rounded-full bg-primary/10 px-2 py-1 text-[10px] font-bold text-primary">{selectedType?.name}</span>
            </div>
            
            <div className="flex justify-between items-center bg-muted/30 p-3 rounded-xl mb-2">
              <div className="flex items-center gap-2 text-sm font-semibold">
                <Clock className="h-4 w-4 text-primary" /> ETA
              </div>
              <span className="text-sm font-bold">{selectedType?.eta}</span>
            </div>
            
            <div className="flex justify-between items-center bg-muted/30 p-3 rounded-xl">
              <div className="flex items-center gap-2 text-sm font-semibold">
                <IndianRupee className="h-4 w-4 text-primary" /> Estimated Cost
              </div>
              <span className="text-sm font-bold">{selectedType?.price}</span>
            </div>
            
            <div className="mt-3 flex items-start gap-2 rounded-xl bg-info/10 p-3 text-xs text-info-foreground border border-info/20">
              <Info className="h-4 w-4 shrink-0 mt-0.5" />
              <p>Final cost may vary based on exact distance and medical supplies used.</p>
            </div>
          </div>
        </div>

      </div>

      {/* Bottom Sticky Action */}
      <div className="fixed bottom-0 left-0 right-0 border-t border-border bg-white p-6 shadow-[0_-10px_20px_rgba(0,0,0,0.05)]">
        <div className="mx-auto w-full">
          <button
            onClick={() => setShowModal(true)}
            className="w-full rounded-[16px] bg-[#D66B6B] py-4 font-bold text-white shadow-lg shadow-[#D66B6B]/30 transition-all hover:bg-[#c05959] active:scale-95 flex items-center justify-center gap-2"
          >
            <AlertTriangle className="h-5 w-5" />
            REQUEST AMBULANCE NOW
          </button>
        </div>
      </div>

      {/* Confirmation Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm px-4">
          <div className="w-full max-w-sm rounded-[24px] bg-white p-6 shadow-2xl animate-in fade-in zoom-in duration-200">
            <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-[#D66B6B]/10 text-[#D66B6B]">
              <Ambulance className="h-8 w-8" />
            </div>
            <h2 className="text-center font-heading text-xl font-bold mb-2">Confirm Emergency</h2>
            <p className="text-center text-sm text-muted-foreground mb-6">
              Are you sure you want to request a {selectedType?.name}? False alarms may result in penalties.
            </p>
            <div className="flex gap-3">
              <button 
                onClick={() => setShowModal(false)}
                className="flex-1 rounded-[14px] border border-border bg-white py-3 font-semibold text-foreground hover:bg-muted transition-colors"
              >
                Cancel
              </button>
              <button 
                onClick={handleConfirm}
                className="flex-1 rounded-[14px] bg-[#D66B6B] py-3 font-bold text-white shadow-md hover:bg-[#c05959] transition-colors"
              >
                Confirm
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
