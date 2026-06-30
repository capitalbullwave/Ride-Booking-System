import { Suspense } from "react";
import { OTPView } from "@/components/auth";

function OTPFallback() {
  return (
    <div className="flex h-screen w-full items-center justify-center bg-background text-muted-foreground">
      Loading…
    </div>
  );
}

export default function OTPPage() {
  return (
    <Suspense fallback={<OTPFallback />}>
      <OTPView />
    </Suspense>
  );
}
