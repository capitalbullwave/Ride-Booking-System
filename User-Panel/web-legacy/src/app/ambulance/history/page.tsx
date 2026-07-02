"use client";

import { useRouter } from "next/navigation";
import { ChevronLeft, FileText, CheckCircle2 } from "lucide-react";
import { mockPastEmergencies } from "@/data/mock/ambulance";

export default function EmergencyHistoryPage() {
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
        <h1 className="ml-2 font-heading text-lg font-bold">Emergency History</h1>
      </div>

      {/* Main Content */}
      <div className="mx-auto w-full flex-1 px-4 py-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {mockPastEmergencies.map((booking) => (
            <div key={booking.id} className="flex flex-col gap-3 rounded-[20px] border border-border bg-white p-5 shadow-sm transition-all hover:shadow-md">
              <div className="flex justify-between items-start border-b border-border pb-3">
                <div>
                  <h3 className="font-heading font-bold text-foreground text-sm">{booking.patientName}</h3>
                  <p className="text-[10px] text-muted-foreground">{booking.date}</p>
                </div>
                <div className="flex items-center gap-1 rounded-full bg-success/10 px-2 py-1 text-[10px] font-bold text-success">
                  <CheckCircle2 className="h-3 w-3" />
                  {booking.status}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-y-3">
                <div>
                  <p className="text-[10px] text-muted-foreground">Booking ID</p>
                  <p className="text-xs font-mono font-bold">{booking.id}</p>
                </div>
                <div>
                  <p className="text-[10px] text-muted-foreground">Invoice</p>
                  <p className="text-xs font-bold">{booking.invoice}</p>
                </div>
                <div className="col-span-2">
                  <p className="text-[10px] text-muted-foreground">Ambulance Type</p>
                  <p className="text-xs font-semibold text-[#D66B6B]">{booking.ambulanceType}</p>
                </div>
                <div className="col-span-2">
                  <p className="text-[10px] text-muted-foreground">Destination</p>
                  <p className="text-xs font-semibold">{booking.hospital}</p>
                </div>
              </div>

              <div className="mt-2 flex">
                <button className="flex w-full items-center justify-center gap-2 rounded-[12px] bg-muted py-2.5 text-xs font-bold text-foreground transition-colors hover:bg-muted/80">
                  <FileText className="h-4 w-4" /> View Invoice
                </button>
              </div>
            </div>
          ))}

          {mockPastEmergencies.length === 0 && (
            <div className="py-12 text-center text-muted-foreground col-span-full">
              No past emergency bookings found.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
