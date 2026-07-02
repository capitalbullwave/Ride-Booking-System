"use client";

import { Suspense } from "react";
import { useSearchParams } from "next/navigation";
import { ContactVerifyForm } from "@/components/profile";
import { ROUTES } from "@/constants/routes";

function EmailVerifyView() {
  const searchParams = useSearchParams();
  const email = searchParams.get("email") ?? "";

  return (
    <ContactVerifyForm
      type="email"
      contact={email}
      backHref={ROUTES.profileEmail}
    />
  );
}

function VerifyFallback() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background text-muted-foreground">
      Loading…
    </div>
  );
}

export default function EmailVerifyPage() {
  return (
    <Suspense fallback={<VerifyFallback />}>
      <EmailVerifyView />
    </Suspense>
  );
}
