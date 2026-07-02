"use client";

import { useRouter } from "next/navigation";
import { ChevronLeft } from "lucide-react";
import { EmergencyForm } from "@/components/ambulance/EmergencyForm";

export default function EmergencyFormPage() {
  const router = useRouter();

  return (
    <div className="flex min-h-screen w-full flex-col bg-background pb-12">
      {/* Top Header */}
      <div className="sticky top-0 z-10 flex h-16 items-center border-b border-border bg-white px-4 shadow-sm">
        <button 
          onClick={() => router.back()}
          className="flex h-10 w-10 items-center justify-center rounded-full hover:bg-muted transition-colors"
        >
          <ChevronLeft className="h-6 w-6" />
        </button>
        <h1 className="ml-2 font-heading text-lg font-bold">Emergency Details</h1>
      </div>

      {/* Main Content */}
      <div className="mx-auto w-full flex-1 px-4 py-6">
        <div className="mb-6 rounded-[16px] bg-warning/10 p-4 border border-warning/20">
          <p className="text-xs font-medium text-warning-foreground">
            Please fill in these details quickly and accurately. This helps our medical team prepare for the emergency.
          </p>
        </div>

        <EmergencyForm />
      </div>
    </div>
  );
}
