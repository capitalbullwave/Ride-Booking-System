import { Suspense } from "react";
import { RideBookingView } from "@/components/booking";

function BookFallback() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background text-muted-foreground">
      Loading ride options…
    </div>
  );
}

export default function BookPage() {
  return (
    <Suspense fallback={<BookFallback />}>
      <RideBookingView />
    </Suspense>
  );
}
