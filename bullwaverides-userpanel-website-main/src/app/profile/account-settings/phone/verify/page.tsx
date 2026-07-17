"use client";

import { Suspense } from "react";
import { useSearchParams } from "next/navigation";
import { ContactVerifyForm } from "@/components/profile";
import { ROUTES } from "@/constants/routes";

function PhoneVerifyView() {
  const searchParams = useSearchParams();
  const contact = searchParams.get("contact") ?? "";

  return (
    <ContactVerifyForm
      type="phone"
      contact={contact}
      backHref={ROUTES.profilePhone}
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

export default function PhoneVerifyPage() {
  return (
    <Suspense fallback={<VerifyFallback />}>
      <PhoneVerifyView />
    </Suspense>
  );
}
