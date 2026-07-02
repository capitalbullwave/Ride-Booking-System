"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { ArrowLeft, ArrowRight } from "lucide-react";
import { SettingsHeader } from "@/components/layout";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { VerificationCodeInput } from "@/components/profile/VerificationCodeInput";

interface ContactVerifyFormProps {
  type: "email" | "phone";
  contact: string;
  backHref: string;
  successHref?: string;
}

export function ContactVerifyForm({
  type,
  contact,
  backHref,
  successHref = "/profile/account-settings",
}: ContactVerifyFormProps) {
  const router = useRouter();
  const [code, setCode] = useState("");
  const [timeLeft, setTimeLeft] = useState(30);

  useEffect(() => {
    if (timeLeft <= 0) return;
    const timer = setTimeout(() => setTimeLeft((prev) => prev - 1), 1000);
    return () => clearTimeout(timer);
  }, [timeLeft]);

  const isComplete = code.length === 4;

  const handleNext = () => {
    if (!isComplete) return;
    router.push(successHref);
  };

  const handleResend = () => {
    setCode("");
    setTimeLeft(30);
  };

  return (
    <div className="flex min-h-screen flex-col bg-background pb-8">
      <SettingsHeader backHref={backHref} />

      <div className="flex w-full flex-1 flex-col px-6 py-6 md:px-12 lg:px-24">
        <h1 className="font-heading text-2xl font-bold leading-snug text-foreground md:text-3xl">
          Enter the 4-digit code sent to you at{" "}
          <span className="break-all">{contact}</span>
        </h1>

        <div className="mt-10 flex flex-1 flex-col">
          {type === "phone" && (
            <Label className="mb-3 text-sm font-semibold text-foreground">
              4-digit code
            </Label>
          )}

          <VerificationCodeInput value={code} onChange={setCode} />

          {type === "email" ? (
            <>
              <p className="mt-4 text-sm text-muted-foreground">
                Tip: Make sure to check your inbox and spam folders
              </p>
              <button
                type="button"
                onClick={handleResend}
                className="mt-4 w-fit rounded-full bg-muted px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-muted/80"
              >
                Resend
              </button>
            </>
          ) : (
            <button
              type="button"
              onClick={handleResend}
              disabled={timeLeft > 0}
              className="mt-4 w-fit rounded-full bg-muted px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-muted/80 disabled:opacity-60"
            >
              {timeLeft > 0
                ? `More options (0:${timeLeft.toString().padStart(2, "0")})`
                : "Resend code"}
            </button>
          )}
        </div>

        <div className="mt-auto flex items-center justify-between pt-10">
          <button
            type="button"
            onClick={() => router.push(backHref)}
            className="flex h-11 w-11 items-center justify-center rounded-full bg-muted transition-colors hover:bg-muted/80"
            aria-label="Go back"
          >
            <ArrowLeft className="h-5 w-5 text-foreground" />
          </button>

          <Button
            type="button"
            onClick={handleNext}
            disabled={!isComplete}
            className="h-11 rounded-full px-6 font-semibold disabled:bg-muted disabled:text-muted-foreground"
          >
            Next
            <ArrowRight className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  );
}
