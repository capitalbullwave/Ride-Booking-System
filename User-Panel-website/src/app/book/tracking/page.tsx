import { Suspense } from "react";
import { RideTrackingView } from "@/components/booking";

function TrackingFallback() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background text-muted-foreground">
      Loading tracking…
    </div>
  );
}

export default function RideTrackingPage() {
  return (
    <Suspense fallback={<TrackingFallback />}>
      <RideTrackingView />
    </Suspense>
  );
}
