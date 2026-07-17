"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AnimatePresence, motion } from "framer-motion";
import { Loader2, Mail, User } from "lucide-react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { LoginSceneDecor } from "@/components/auth/LoginSceneDecor";
import { ROUTES } from "@/constants/routes";
import {
  getAuthSession,
  markProfileComplete,
  needsProfileSetup,
  resolvePostAuthDestination,
} from "@/lib/auth-session";
import { updateProfile } from "@/lib/profile-api";
import { transitions } from "@/lib/motion";
import { cn } from "@/lib/utils";

function isValidEmail(value: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim());
}

const inputClass = (hasError: boolean) =>
  cn(
    "h-11 rounded-[18px] border-border bg-background text-base text-foreground transition-all placeholder:text-muted-foreground/60 focus-visible:border-primary focus-visible:ring-2 focus-visible:ring-primary/15 sm:h-12",
    hasError && "border-destructive focus-visible:border-destructive focus-visible:ring-destructive/20"
  );

export function CreateProfileView() {
  const router = useRouter();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [nameError, setNameError] = useState("");
  const [emailError, setEmailError] = useState("");
  const [submitError, setSubmitError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev;
    };
  }, []);

  useEffect(() => {
    const session = getAuthSession();
    if (!session) {
      router.replace(ROUTES.login);
      return;
    }
    if (session.profileComplete || !needsProfileSetup(session.name)) {
      if (!session.profileComplete) {
        markProfileComplete({ name: session.name, email: session.email });
      }
      router.replace(resolvePostAuthDestination());
      return;
    }
    setPhone(session.phone);
    if (session.name && session.name.trim().toLowerCase() !== "user") {
      setFullName(session.name.trim());
    }
    if (session.email) setEmail(session.email);
  }, [router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitError("");
    setNameError("");
    setEmailError("");

    const trimmedName = fullName.trim();
    if (!trimmedName) {
      setNameError("Please enter your full name");
      return;
    }
    if (trimmedName.length < 2) {
      setNameError("Name must be at least 2 characters");
      return;
    }
    if (email.trim() && !isValidEmail(email)) {
      setEmailError("Please enter a valid email address");
      return;
    }

    setIsSubmitting(true);

    try {
      await updateProfile({
        full_name: trimmedName,
        ...(email.trim() ? { email: email.trim() } : {}),
      });

      markProfileComplete({
        name: trimmedName,
        ...(email.trim() ? { email: email.trim() } : {}),
      });

      router.push(resolvePostAuthDestination());
    } catch (error) {
      setSubmitError(
        error instanceof Error ? error.message : "Unable to save your details. Please try again."
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="relative flex min-h-[100dvh] overflow-hidden bg-background font-sans">
      <LoginSceneDecor />

      <div className="relative z-10 flex w-full flex-col items-center justify-center px-4 py-10 sm:px-6">
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={transitions.reveal}
          className="w-full max-w-md rounded-[28px] border border-border bg-card/95 p-6 shadow-xl backdrop-blur-sm sm:p-8"
        >
          <div className="mb-6">
            <h1 className="font-heading text-2xl font-bold text-foreground">
              Complete your profile
            </h1>
            <p className="mt-2 text-sm text-muted-foreground">
              Tell us a bit about yourself to finish setting up your account
            </p>
          </div>

          {phone ? (
            <div className="mb-5 rounded-[16px] border border-border/60 bg-muted/40 px-4 py-3">
              <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                Verified mobile
              </p>
              <p className="mt-0.5 text-sm font-semibold text-foreground">{phone}</p>
            </div>
          ) : null}

          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="fullName" className="text-sm font-semibold text-foreground">
                Full name
              </Label>
              <div className="relative">
                <User className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  id="fullName"
                  type="text"
                  autoComplete="name"
                  placeholder="Enter your full name"
                  value={fullName}
                  onChange={(e) => {
                    setFullName(e.target.value);
                    if (nameError) setNameError("");
                  }}
                  aria-invalid={!!nameError}
                  className={cn(inputClass(!!nameError), "pl-10")}
                />
              </div>
              <AnimatePresence>
                {nameError && (
                  <motion.p
                    initial={{ opacity: 0, y: -4 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0 }}
                    className="text-sm font-medium text-destructive"
                  >
                    {nameError}
                  </motion.p>
                )}
              </AnimatePresence>
            </div>

            <div className="flex flex-col gap-1.5">
              <Label htmlFor="email" className="text-sm font-semibold text-foreground">
                Email{" "}
                <span className="font-normal text-muted-foreground">(optional)</span>
              </Label>
              <div className="relative">
                <Mail className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  id="email"
                  type="email"
                  autoComplete="email"
                  placeholder="you@example.com"
                  value={email}
                  onChange={(e) => {
                    setEmail(e.target.value);
                    if (emailError) setEmailError("");
                  }}
                  aria-invalid={!!emailError}
                  className={cn(inputClass(!!emailError), "pl-10")}
                />
              </div>
              <AnimatePresence>
                {emailError && (
                  <motion.p
                    initial={{ opacity: 0, y: -4 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0 }}
                    className="text-sm font-medium text-destructive"
                  >
                    {emailError}
                  </motion.p>
                )}
              </AnimatePresence>
            </div>

            {submitError && (
              <p className="text-sm font-medium text-destructive">{submitError}</p>
            )}

            <Button
              type="submit"
              disabled={isSubmitting}
              className="h-12 w-full rounded-[16px] text-base font-semibold"
            >
              {isSubmitting ? (
                <span className="inline-flex items-center gap-2">
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Saving…
                </span>
              ) : (
                "Continue to home"
              )}
            </Button>
          </form>

          <p className="mt-6 text-center text-xs text-muted-foreground">
            By continuing, you agree to Bull Wave rides&apos;s{" "}
            <Link href={ROUTES.terms} className="font-semibold text-primary hover:underline">
              Terms
            </Link>{" "}
            and{" "}
            <Link href={ROUTES.privacy} className="font-semibold text-primary hover:underline">
              Privacy Policy
            </Link>
          </p>
        </motion.div>
      </div>
    </div>
  );
}
