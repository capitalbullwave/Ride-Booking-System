"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AnimatePresence, motion } from "framer-motion";
import { Eye, EyeOff, Loader2, Mail, User } from "lucide-react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { CountryCodeSelector } from "@/components/auth/CountryCodeSelector";
import { LoginSceneDecor } from "@/components/auth/LoginSceneDecor";
import { LoginServicesPanel } from "@/components/auth/LoginServicesPanel";
import { ROUTES } from "@/constants/routes";
import { setDevOtpHint, setPendingOtpPhone } from "@/lib/auth-session";
import { sendSignupOtp } from "@/lib/auth-api";
import {
  defaultCountry,
  formatPhoneDisplay,
  getPhonePlaceholder,
  isValidPhoneNumber,
  parsePhoneDisplay,
  sanitizePhoneInput,
  type Country,
} from "@/lib/countries";
import { easeOut, transitions } from "@/lib/motion";
import { cn } from "@/lib/utils";

interface FormErrors {
  name?: string;
  phone?: string;
  email?: string;
  password?: string;
  confirmPassword?: string;
  terms?: string;
}

function isValidEmail(value: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim());
}

const inputClass = (hasError: boolean) =>
  cn(
    "h-11 rounded-[18px] border-border bg-background text-base text-foreground transition-all placeholder:text-muted-foreground/60 focus-visible:border-primary focus-visible:ring-2 focus-visible:ring-primary/15 sm:h-12",
    hasError && "border-destructive focus-visible:border-destructive focus-visible:ring-destructive/20"
  );

export function SignupView() {
  const router = useRouter();

  const [country, setCountry] = useState<Country>(defaultCountry);
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [mobileNumber, setMobileNumber] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [termsAgreed, setTermsAgreed] = useState(false);
  const [errors, setErrors] = useState<FormErrors>({});
  const [submitError, setSubmitError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev;
    };
  }, []);

  const clearError = (key: keyof FormErrors) => {
    setErrors((prev) => {
      if (!prev[key]) return prev;
      const next = { ...prev };
      delete next[key];
      return next;
    });
  };

  const validate = (): FormErrors => {
    const next: FormErrors = {};
    const trimmedName = fullName.trim();

    if (!trimmedName) {
      next.name = "Please enter your full name";
    } else if (trimmedName.length < 2) {
      next.name = "Name must be at least 2 characters";
    }

    if (!isValidPhoneNumber(mobileNumber, country)) {
      next.phone = "Please enter a valid phone number";
    }

    if (email.trim() && !isValidEmail(email)) {
      next.email = "Please enter a valid email address";
    }

    if (!password) {
      next.password = "Password is required";
    } else if (password.length < 8) {
      next.password = "Password must be at least 8 characters";
    }

    if (!confirmPassword) {
      next.confirmPassword = "Please confirm your password";
    } else if (password !== confirmPassword) {
      next.confirmPassword = "Passwords do not match";
    }

    if (!termsAgreed) {
      next.terms = "You must agree to continue";
    }

    return next;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitError("");
    const nextErrors = validate();
    setErrors(nextErrors);

    if (Object.keys(nextErrors).length > 0) {
      return;
    }

    setIsSubmitting(true);

    try {
      const result = await sendSignupOtp({
        dial_code: country.dialCode,
        phone: mobileNumber,
        full_name: fullName.trim(),
        email: email.trim() || undefined,
        password,
        confirm_password: confirmPassword,
        terms_agreed: termsAgreed,
      });

      setPendingOtpPhone(result.phone);
      if (result.dev_otp) setDevOtpHint(result.dev_otp);
      router.push(`${ROUTES.otp}?phone=${encodeURIComponent(result.phone)}&mode=signup`);
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Unable to create account. Please try again.";

      if (message.toLowerCase().includes("passwords do not match")) {
        setErrors((prev) => ({ ...prev, confirmPassword: message }));
      } else if (message.toLowerCase().includes("already registered")) {
        setErrors((prev) => ({ ...prev, phone: message }));
      } else if (message.toLowerCase().includes("email")) {
        setErrors((prev) => ({ ...prev, email: message }));
      } else {
        setSubmitError(message);
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.45, ease: easeOut }}
      className="relative flex h-[100dvh] overflow-hidden bg-background font-sans"
    >
      <LoginSceneDecor />

      <div className="relative z-10 flex h-full w-full items-center justify-center px-4 py-4 sm:px-6 lg:px-8 lg:py-3">
        <div className="flex w-full max-w-7xl flex-col items-center gap-6 lg:flex-row lg:items-center lg:justify-between lg:gap-8 xl:gap-12">
          <div className="hidden w-full min-w-0 flex-1 lg:block lg:max-w-[56%]">
            <LoginServicesPanel />
          </div>

          <motion.div
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ ...transitions.reveal, delay: 0.08 }}
            className="w-full max-w-[440px] shrink-0"
          >
            <div className="max-h-[calc(100dvh-2rem)] overflow-y-auto rounded-[20px] border border-border/60 bg-card p-6 shadow-[0_20px_60px_-24px_rgba(49,82,110,0.18)] sm:p-8">
            <div className="mb-5">
              <h1 className="font-heading text-2xl font-bold text-primary sm:text-[1.65rem]">
                Join Bull Wave rides
              </h1>
              <p className="mt-1.5 text-sm text-muted-foreground">
                Create your account to get started
              </p>
            </div>

            <form onSubmit={handleSubmit} className="flex flex-col gap-3.5 sm:gap-4">
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
                      clearError("name");
                    }}
                    aria-invalid={!!errors.name}
                    className={cn(inputClass(!!errors.name), "pl-10")}
                  />
                </div>
                <AnimatePresence>
                  {errors.name && (
                    <motion.p
                      initial={{ opacity: 0, y: -4 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0 }}
                      className="text-sm font-medium text-destructive"
                    >
                      {errors.name}
                    </motion.p>
                  )}
                </AnimatePresence>
              </div>

              <div className="flex flex-col gap-1.5">
                <Label htmlFor="phone" className="text-sm font-semibold text-foreground">
                  Phone number
                </Label>
                <div className="flex gap-2.5">
                  <CountryCodeSelector
                    value={country}
                    onChange={(selected) => {
                      setCountry(selected);
                      setMobileNumber((prev) => sanitizePhoneInput(prev, selected));
                      clearError("phone");
                    }}
                    size="lg"
                    showDialCode
                    className="h-11 rounded-[18px] border-border bg-background px-3 shadow-sm sm:h-12"
                  />
                  <Input
                    id="phone"
                    type="tel"
                    inputMode="numeric"
                    autoComplete="tel-national"
                    placeholder={getPhonePlaceholder(country)}
                    maxLength={country.maxLength + 1}
                    value={formatPhoneDisplay(mobileNumber, country)}
                    onChange={(e) => {
                      setMobileNumber(parsePhoneDisplay(e.target.value, country));
                      clearError("phone");
                    }}
                    aria-invalid={!!errors.phone}
                    className={cn(inputClass(!!errors.phone), "min-w-0 flex-1")}
                  />
                </div>
                <AnimatePresence>
                  {errors.phone && (
                    <motion.p
                      initial={{ opacity: 0, y: -4 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0 }}
                      className="text-sm font-medium text-destructive"
                    >
                      {errors.phone}
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
                      clearError("email");
                    }}
                    aria-invalid={!!errors.email}
                    className={cn(inputClass(!!errors.email), "pl-10")}
                  />
                </div>
                <AnimatePresence>
                  {errors.email && (
                    <motion.p
                      initial={{ opacity: 0, y: -4 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0 }}
                      className="text-sm font-medium text-destructive"
                    >
                      {errors.email}
                    </motion.p>
                  )}
                </AnimatePresence>
              </div>

              <div className="grid gap-3.5 sm:grid-cols-2 sm:gap-4">
                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="password" className="text-sm font-semibold text-foreground">
                    Password
                  </Label>
                  <div className="relative">
                    <Input
                      id="password"
                      type={showPassword ? "text" : "password"}
                      autoComplete="new-password"
                      placeholder="Min. 8 characters"
                      value={password}
                      onChange={(e) => {
                        setPassword(e.target.value);
                        clearError("password");
                      }}
                      aria-invalid={!!errors.password}
                      className={cn(inputClass(!!errors.password), "pr-10")}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword((v) => !v)}
                      className="absolute right-2.5 top-1/2 flex h-8 w-8 -translate-y-1/2 items-center justify-center rounded-lg text-muted-foreground hover:bg-muted hover:text-primary"
                      aria-label={showPassword ? "Hide password" : "Show password"}
                    >
                      {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </button>
                  </div>
                  <AnimatePresence>
                    {errors.password && (
                      <motion.p
                        initial={{ opacity: 0, y: -4 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0 }}
                        className="text-sm font-medium text-destructive"
                      >
                        {errors.password}
                      </motion.p>
                    )}
                  </AnimatePresence>
                </div>

                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="confirmPassword" className="text-sm font-semibold text-foreground">
                    Confirm password
                  </Label>
                  <div className="relative">
                    <Input
                      id="confirmPassword"
                      type={showConfirmPassword ? "text" : "password"}
                      autoComplete="new-password"
                      placeholder="Re-enter password"
                      value={confirmPassword}
                      onChange={(e) => {
                        setConfirmPassword(e.target.value);
                        clearError("confirmPassword");
                      }}
                      aria-invalid={!!errors.confirmPassword}
                      className={cn(inputClass(!!errors.confirmPassword), "pr-10")}
                    />
                    <button
                      type="button"
                      onClick={() => setShowConfirmPassword((v) => !v)}
                      className="absolute right-2.5 top-1/2 flex h-8 w-8 -translate-y-1/2 items-center justify-center rounded-lg text-muted-foreground hover:bg-muted hover:text-primary"
                      aria-label={showConfirmPassword ? "Hide password" : "Show password"}
                    >
                      {showConfirmPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </button>
                  </div>
                  <AnimatePresence>
                    {errors.confirmPassword && (
                      <motion.p
                        initial={{ opacity: 0, y: -4 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0 }}
                        className="text-sm font-medium text-destructive"
                      >
                        {errors.confirmPassword}
                      </motion.p>
                    )}
                  </AnimatePresence>
                </div>
              </div>

              <div className="flex flex-col gap-1">
                <label className="flex cursor-pointer items-start gap-2.5 text-sm text-muted-foreground">
                  <input
                    type="checkbox"
                    checked={termsAgreed}
                    onChange={(e) => {
                      setTermsAgreed(e.target.checked);
                      clearError("terms");
                    }}
                    className="mt-0.5 h-4 w-4 shrink-0 rounded border-border accent-primary"
                  />
                  <span>
                    I agree to Bull Wave rides&apos;s{" "}
                    <Link href={ROUTES.terms} className="font-semibold text-primary hover:underline">
                      Terms
                    </Link>
                    ,{" "}
                    <Link href={ROUTES.privacy} className="font-semibold text-primary hover:underline">
                      Privacy Policy
                    </Link>
                    , and{" "}
                    <Link href={ROUTES.safety} className="font-semibold text-primary hover:underline">
                      Safety Policy
                    </Link>
                  </span>
                </label>
                {errors.terms && (
                  <p className="text-sm font-medium text-destructive">{errors.terms}</p>
                )}
              </div>

              {submitError && (
                <p className="text-sm font-medium text-destructive">{submitError}</p>
              )}

              <motion.div whileTap={{ scale: 0.98 }} transition={transitions.fast}>
                <Button
                  type="submit"
                  disabled={isSubmitting}
                  className="h-11 w-full rounded-[16px] bg-primary text-base font-bold text-primary-foreground shadow-md shadow-primary/20 hover:bg-primary/90 sm:h-12"
                >
                  {isSubmitting ? (
                    <span className="inline-flex items-center gap-2">
                      <Loader2 className="h-4 w-4 animate-spin" />
                      Sending OTP…
                    </span>
                  ) : (
                    "Send OTP & Continue"
                  )}
                </Button>
              </motion.div>

              <p className="text-center text-xs text-muted-foreground">
                OTP will be sent to verify your phone number
              </p>
            </form>

            <p className="mt-4 text-center text-sm text-muted-foreground">
              Already have an account?{" "}
              <Link href={ROUTES.login} className="font-semibold text-primary hover:underline">
                Sign in
              </Link>
            </p>
            </div>

            <div className="mt-6 lg:hidden">
              <LoginServicesPanel />
            </div>
          </motion.div>
        </div>
      </div>
    </motion.div>
  );
}
