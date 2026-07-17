"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { AnimatePresence, motion, useReducedMotion } from "framer-motion";
import { Eye, EyeOff, Loader2, Smartphone } from "lucide-react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { CountryCodeSelector } from "@/components/auth/CountryCodeSelector";
import { LoginSceneDecor } from "@/components/auth/LoginSceneDecor";
import { LoginServicesPanel } from "@/components/auth/LoginServicesPanel";
import { ROUTES } from "@/constants/routes";
import {
  needsProfileSetup,
  resolvePostAuthDestination,
  setAuthSession,
  setPostLoginRedirect,
} from "@/lib/auth-session";
import {
  defaultCountry,
  formatPhoneDisplay,
  isValidPhoneNumber,
  parsePhoneDisplay,
  sanitizePhoneInput,
  type Country,
} from "@/lib/countries";
import { easeOut, transitions } from "@/lib/motion";
import { loginWithPassword } from "@/lib/auth-api";
import { cn } from "@/lib/utils";

export function LoginView() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const reduceMotion = useReducedMotion();

  const [country, setCountry] = useState<Country>(defaultCountry);
  const [mobileNumber, setMobileNumber] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [remember, setRemember] = useState(false);
  const [phoneError, setPhoneError] = useState("");
  const [passwordError, setPasswordError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isExiting, setIsExiting] = useState(false);

  useEffect(() => {
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev;
    };
  }, []);

  const validatePhone = () => {
    if (!isValidPhoneNumber(mobileNumber, country)) {
      setPhoneError("Please enter a valid phone number");
      return false;
    }
    setPhoneError("");
    return true;
  };

  const handleCountryChange = (selected: Country) => {
    setCountry(selected);
    setMobileNumber((prev) => sanitizePhoneInput(prev, selected));
    if (phoneError) setPhoneError("");
  };

  const finishLogin = async (
    phone: string,
    profile?: { name?: string | null; email?: string | null; accessToken?: string; refreshToken?: string }
  ) => {
    const next = searchParams.get("next") ?? searchParams.get("redirect");
    if (next) setPostLoginRedirect(next);

    const profileComplete = !needsProfileSetup(profile?.name);
    setAuthSession({
      phone,
      verified: true,
      ...(profile?.name?.trim() ? { name: profile.name.trim() } : {}),
      ...(profile?.email?.trim() ? { email: profile.email.trim() } : {}),
      ...(profile?.accessToken ? { accessToken: profile.accessToken } : {}),
      ...(profile?.refreshToken ? { refreshToken: profile.refreshToken } : {}),
      profileComplete,
    });

    await new Promise((resolve) => setTimeout(resolve, 600));
    setIsExiting(true);

    const destination = profileComplete
      ? resolvePostAuthDestination()
      : ROUTES.createProfile;
    await new Promise((resolve) => setTimeout(resolve, reduceMotion ? 0 : 400));
    router.push(destination);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setPasswordError("");

    if (!validatePhone()) return;

    if (!password) {
      setPasswordError("Password is required");
      return;
    }

    setIsSubmitting(true);

    try {
      const result = await loginWithPassword({
        dial_code: country.dialCode,
        phone: mobileNumber,
        password,
        remember,
      });

      await finishLogin(result.user.phone, {
        name: result.user.name,
        email: result.user.email,
        accessToken: result.access_token,
        refreshToken: result.refresh_token,
      });
    } catch (error) {
      setPasswordError(
        error instanceof Error ? error.message : "Unable to sign in. Please try again."
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleOtpContinue = () => {
    const next = searchParams.get("next") ?? searchParams.get("redirect");
    const params = new URLSearchParams();
    if (next) params.set("next", next);
    const query = params.toString();
    router.push(query ? `${ROUTES.login}?${query}` : ROUTES.login);
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: isExiting ? 0 : 1 }}
      transition={{ duration: 0.45, ease: easeOut }}
      className="relative flex h-[100dvh] overflow-hidden bg-background font-sans"
    >
      <LoginSceneDecor />

      <div className="relative z-10 flex h-full w-full items-center justify-center px-4 py-4 sm:px-6 lg:px-8 lg:py-3">
        <div className="flex w-full max-w-7xl flex-col items-center gap-8 lg:flex-row lg:items-center lg:justify-between lg:gap-8 xl:gap-12">
          <div className="hidden w-full min-w-0 flex-1 lg:block lg:max-w-[56%]">
            <LoginServicesPanel />
          </div>

          <motion.div
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ ...transitions.reveal, delay: 0.08 }}
            className="w-full max-w-[440px] shrink-0 lg:max-w-[420px]"
          >
            <div className="rounded-[20px] border border-border/60 bg-card p-6 shadow-[0_20px_60px_-24px_rgba(49,82,110,0.18)] sm:p-8">
              <div className="mb-6">
                <h1 className="font-heading text-2xl font-bold text-primary sm:text-[1.65rem]">
                  Welcome Back
                </h1>
                <p className="mt-1.5 text-sm text-muted-foreground">
                  Enter your details to continue
                </p>
              </div>

              <form onSubmit={handleSubmit} className="flex flex-col gap-4">
                <div className="flex flex-col gap-2">
                  <Label htmlFor="phone" className="text-sm font-semibold text-foreground">
                    Phone number
                  </Label>
                  <div className="flex gap-2">
                    <CountryCodeSelector
                      value={country}
                      onChange={handleCountryChange}
                      size="lg"
                      showDialCode
                      className="h-11 rounded-[18px] border-border bg-background px-2.5 shadow-sm sm:h-12"
                    />
                    <Input
                      id="phone"
                      type="tel"
                      inputMode="numeric"
                      autoComplete="tel-national"
                      placeholder="Enter your phone number"
                      maxLength={country.maxLength + 1}
                      value={formatPhoneDisplay(mobileNumber, country)}
                      onChange={(e) => {
                        setMobileNumber(parsePhoneDisplay(e.target.value, country));
                        if (phoneError) setPhoneError("");
                      }}
                      aria-invalid={!!phoneError}
                      className={cn(
                        "h-11 min-w-0 flex-1 rounded-[18px] border-border bg-background sm:h-12",
                        phoneError && "border-destructive"
                      )}
                    />
                  </div>
                  <AnimatePresence>
                    {phoneError && (
                      <motion.p
                        initial={{ opacity: 0, y: -4 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0 }}
                        className="text-sm text-destructive"
                      >
                        {phoneError}
                      </motion.p>
                    )}
                  </AnimatePresence>
                </div>

                <div className="flex flex-col gap-2">
                  <Label htmlFor="password" className="text-sm font-semibold text-foreground">
                    Password
                  </Label>
                  <div className="relative">
                    <Input
                      id="password"
                      type={showPassword ? "text" : "password"}
                      autoComplete="current-password"
                      placeholder="Enter your password"
                      value={password}
                      onChange={(e) => {
                        setPassword(e.target.value);
                        if (passwordError) setPasswordError("");
                      }}
                      aria-invalid={!!passwordError}
                      className={cn(
                        "h-11 rounded-[18px] border-border bg-background pr-11 sm:h-12",
                        passwordError && "border-destructive"
                      )}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword((v) => !v)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-primary"
                      aria-label={showPassword ? "Hide password" : "Show password"}
                    >
                      {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </button>
                  </div>
                  <AnimatePresence>
                    {passwordError && (
                      <motion.p
                        initial={{ opacity: 0, y: -4 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0 }}
                        className="text-sm text-destructive"
                      >
                        {passwordError}
                      </motion.p>
                    )}
                  </AnimatePresence>
                </div>

                <div className="flex items-center justify-between text-sm">
                  <label className="flex cursor-pointer items-center gap-2 text-muted-foreground">
                    <input
                      type="checkbox"
                      checked={remember}
                      onChange={(e) => setRemember(e.target.checked)}
                      className="h-4 w-4 accent-primary"
                    />
                    Remember me
                  </label>
                  <Link
                    href="#"
                    className="font-medium text-muted-foreground hover:text-primary"
                    onClick={(e) => e.preventDefault()}
                  >
                    Forgot password?
                  </Link>
                </div>

                <Button
                  type="submit"
                  disabled={isSubmitting}
                  className="h-11 w-full rounded-[16px] bg-primary text-base font-bold shadow-md shadow-primary/15 sm:h-12"
                >
                  {isSubmitting ? (
                    <span className="inline-flex items-center gap-2">
                      <Loader2 className="h-4 w-4 animate-spin" />
                      Signing in…
                    </span>
                  ) : (
                    "Sign In"
                  )}
                </Button>

                <div className="relative py-1">
                  <div className="absolute inset-0 flex items-center" aria-hidden>
                    <div className="w-full border-t border-border" />
                  </div>
                  <p className="relative mx-auto w-fit bg-card px-3 text-xs text-muted-foreground">
                    or continue with
                  </p>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handleOtpContinue}
                    className="h-11 rounded-[16px] border-border text-sm font-semibold"
                  >
                    <Smartphone className="mr-1.5 h-4 w-4" />
                    Continue with OTP
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    className="h-11 rounded-[16px] border-border text-sm font-semibold"
                  >
                    <span className="mr-1.5 flex h-5 w-5 items-center justify-center rounded-full bg-secondary text-[10px] font-bold text-secondary-foreground">
                      G
                    </span>
                    Google
                  </Button>
                </div>
              </form>

              <p className="mt-6 text-center text-sm text-muted-foreground">
                Don&apos;t have an account?{" "}
                <Link href={ROUTES.signup} className="font-semibold text-primary hover:underline">
                  Sign up
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
