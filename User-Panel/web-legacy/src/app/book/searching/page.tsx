import { Suspense } from "react";
import { RideSearchingView } from "@/components/booking";

function SearchingFallback() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background text-muted-foreground">
      Finding your ride…
    </div>
  );
}

export default function RideSearchingPage() {
  return (
    <Suspense fallback={<SearchingFallback />}>
      <RideSearchingView />
    </Suspense>
  );
}
