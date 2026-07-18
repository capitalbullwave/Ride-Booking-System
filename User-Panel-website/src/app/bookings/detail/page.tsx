"use client";

import { Suspense } from "react";
import { Loader2 } from "lucide-react";
import { BookingDetailView } from "@/components/bookings/BookingDetailView";

function Fallback() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <Loader2 className="h-8 w-8 animate-spin text-primary" />
    </div>
  );
}

export default function BookingDetailPage() {
  return (
    <Suspense fallback={<Fallback />}>
      <BookingDetailView />
    </Suspense>
  );
}
