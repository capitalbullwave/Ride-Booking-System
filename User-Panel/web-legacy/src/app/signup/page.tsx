import { Suspense } from "react";
import { SignupView } from "@/components/auth";

function SignupFallback() {
  return (
    <div className="flex h-[100dvh] w-full items-center justify-center overflow-hidden bg-background text-muted-foreground">
      Loading…
    </div>
  );
}

export default function SignupPage() {
  return (
    <Suspense fallback={<SignupFallback />}>
      <SignupView />
    </Suspense>
  );
}
