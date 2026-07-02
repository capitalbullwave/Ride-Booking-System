import { Suspense } from "react";
import { LocationSearchView } from "@/components/location";

function LocationSearchFallback() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background font-sans text-muted-foreground">
      Loading…
    </div>
  );
}

export default function LocationPage() {
  return (
    <Suspense fallback={<LocationSearchFallback />}>
      <LocationSearchView />
    </Suspense>
  );
}
