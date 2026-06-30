import { Suspense } from "react";
import { LandingView } from "@/components/landing";

function LandingFallback() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background text-muted-foreground">
      Loading…
    </div>
  );
}

export default function LandingPage() {
  return (
    <Suspense fallback={<LandingFallback />}>
      <LandingView />
    </Suspense>
  );
}
