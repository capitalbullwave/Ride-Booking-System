"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import type { ConfirmationResult, RecaptchaVerifier } from "firebase/auth";
import { ArrowLeft, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { OTPInput } from "@/components/OTPInput";
import { PhoneInput, toE164Phone, isValidPhoneNumber } from "@/components/PhoneInput";
import { Recaptcha } from "@/components/Recaptcha";
import { LoginSceneDecor } from "@/components/auth/LoginSceneDecor";
import { ROUTES } from "@/constants/routes";
import { isFirebaseConfigured } from "@/firebase/firebase";
import {
  needsProfileSetup,
  resolvePostAuthDestination,
  setAuthSession,
  setPostLoginRedirect,
} from "@/lib/auth-session";
import { sendLoginOtp, verifyOtp } from "@/lib/auth-api";
import { defaultCountry, type Country } from "@/lib/countries";
import {
  loginWithFirebaseToken,
  mapFirebaseError,
  sendPhoneOtp as sendFirebasePhoneOtp,
  verifyPhoneOtp,
} from "@/services/authService";

type Step = "phone" | "verify";

export function PhoneLogin() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const [step, setStep] = useState<Step>("phone");
  const [country, setCountry] = useState<Country>(defaultCountry);
  const [phone, setPhone] = useState("");
  const [otp, setOtp] = useState("");
  const [phoneError, setPhoneError] = useState("");
  const [otpError, setOtpError] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [isSending, setIsSending] = useState(false);
  const [isVerifying, setIsVerifying] = useState(false);
  const [resendSeconds, setResendSeconds] = useState(0);
  const [e164Phone, setE164Phone] = useState("");

  const recaptchaVerifier = useRef<RecaptchaVerifier | null>(null);
  const confirmationRef = useRef<ConfirmationResult | null>(null);
  const verifyLock = useRef(false);

  const firebaseReady = isFirebaseConfigured();

  useEffect(() => {
    const next = searchParams.get("next") ?? searchParams.get("redirect");
    if (next) setPostLoginRedirect(next);
  }, [searchParams]);

  useEffect(() => {
    if (resendSeconds <= 0) return;
    const timer = window.setTimeout(() => setResendSeconds((s) => s - 1), 1000);
    return () => window.clearTimeout(timer);
  }, [resendSeconds]);

  const handleVerifierReady = useCallback((verifier: RecaptchaVerifier) => {
    recaptchaVerifier.current = verifier;
  }, []);

  const handleRecaptchaError = useCallback((message: string) => {
    setPhoneError(message);
  }, []);

  const finishLogin = useCallback(
    (phoneDisplay: string, tokens: { accessToken: string; refreshToken?: string; name?: string; email?: string }) => {
      const profileComplete = !needsProfileSetup(tokens.name);
      setAuthSession({
        phone: phoneDisplay,
        verified: true,
        ...(tokens.name ? { name: tokens.name } : {}),
        ...(tokens.email ? { email: tokens.email } : {}),
        accessToken: tokens.accessToken,
        ...(tokens.refreshToken ? { refreshToken: tokens.refreshToken } : {}),
        profileComplete,
      });

      if (!profileComplete) {
        router.push(ROUTES.createProfile);
        return;
      }

      router.push(resolvePostAuthDestination());
    },
    [router]
  );

  const handleSendOtp = async () => {
    if (!isValidPhoneNumber(phone, country)) {
      setPhoneError("Please enter a valid mobile number");
      return;
    }

    setPhoneError("");
    setSuccessMessage("");
    setIsSending(true);

    try {
      if (firebaseReady && recaptchaVerifier.current) {
        const e164 = toE164Phone(country, phone);
        const confirmation = await sendFirebasePhoneOtp(e164, recaptchaVerifier.current);
        confirmationRef.current = confirmation;
        setE164Phone(e164);
      } else {
        await sendLoginOtp({
          dial_code: country.dialCode,
          phone,
          mode: "login",
        });
        setE164Phone(toE164Phone(country, phone));
      }
      setStep("verify");
      setResendSeconds(30);
      setOtp("");
      setSuccessMessage("OTP sent to your mobile number.");
    } catch (error) {
      setPhoneError(
        error instanceof Error ? error.message : mapFirebaseError(error)
      );
      recaptchaVerifier.current?.clear();
      recaptchaVerifier.current = null;
    } finally {
      setIsSending(false);
    }
  };

  const handleVerifyOtp = async () => {
    if (verifyLock.current || otp.length < 4) return;
    if (firebaseReady && !confirmationRef.current && otp.length !== 6) return;

    verifyLock.current = true;
    setOtpError("");
    setIsVerifying(true);

    try {
      if (firebaseReady && confirmationRef.current) {
        const idToken = await verifyPhoneOtp(confirmationRef.current, otp);
        const result = await loginWithFirebaseToken(idToken);
        finishLogin(result.user.phone, {
          accessToken: result.access_token,
          refreshToken: result.refresh_token,
          name: result.user.name ?? undefined,
          email: result.user.email ?? undefined,
        });
      } else {
        const result = await verifyOtp({
          dial_code: country.dialCode,
          phone,
          otp,
          mode: "login",
        });
        finishLogin(result.user.phone, {
          accessToken: result.access_token,
          refreshToken: result.refresh_token,
          name: result.user.name ?? undefined,
          email: result.user.email ?? undefined,
        });
      }
    } catch (error) {
      setOtpError(
        error instanceof Error ? error.message : mapFirebaseError(error)
      );
      verifyLock.current = false;
    } finally {
      setIsVerifying(false);
    }
  };

  const handleResend = async () => {
    if (resendSeconds > 0 || isSending) return;
    setStep("phone");
    setOtp("");
    setOtpError("");
    confirmationRef.current = null;
    await handleSendOtp();
  };

  return (
    <div className="relative flex min-h-[100dvh] overflow-hidden bg-background font-sans">
      <LoginSceneDecor />

      <div className="relative z-10 flex w-full flex-col items-center justify-center px-4 py-10 sm:px-6">
        <div className="w-full max-w-md rounded-[28px] border border-border bg-card/95 p-6 shadow-xl backdrop-blur-sm sm:p-8">
          <header className="mb-6">
            {step === "verify" && (
              <button
                type="button"
                onClick={() => {
                  setStep("phone");
                  setOtp("");
                  setOtpError("");
                }}
                className="mb-4 flex items-center gap-2 text-sm font-medium text-muted-foreground hover:text-foreground"
              >
                <ArrowLeft className="h-4 w-4" />
                Change number
              </button>
            )}
            <h1 className="font-heading text-2xl font-bold text-foreground">
              {step === "phone" ? "Login with mobile" : "Enter OTP"}
            </h1>
            <p className="mt-2 text-sm text-muted-foreground">
              {step === "phone"
                ? firebaseReady
                  ? "We'll send a real SMS verification code to your phone."
                  : "We'll send an OTP to your registered mobile number."
                : `Code sent to ${e164Phone}`}
            </p>
          </header>

          {firebaseReady && (
            <Recaptcha onVerifierReady={handleVerifierReady} onError={handleRecaptchaError} />
          )}

          {step === "phone" ? (
            <div className="space-y-5">
              <PhoneInput
                country={country}
                phone={phone}
                onCountryChange={setCountry}
                onPhoneChange={(value) => {
                  setPhone(value);
                  if (phoneError) setPhoneError("");
                }}
                error={phoneError}
                disabled={isSending}
              />

              {successMessage ? (
                <p className="text-sm font-medium text-success">{successMessage}</p>
              ) : null}

              <Button
                type="button"
                className="h-12 w-full rounded-[16px] text-base font-semibold"
                disabled={isSending}
                onClick={() => void handleSendOtp()}
              >
                {isSending ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Sending OTP…
                  </>
                ) : (
                  "Send OTP"
                )}
              </Button>
            </div>
          ) : (
            <div className="space-y-5">
              <OTPInput value={otp} onChange={setOtp} error={!!otpError} length={6} />

              {otpError ? <p className="text-sm text-destructive">{otpError}</p> : null}

              <Button
                type="button"
                className="h-12 w-full rounded-[16px] text-base font-semibold"
                disabled={isVerifying || otp.length < 4}
                onClick={() => void handleVerifyOtp()}
              >
                {isVerifying ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Verifying…
                  </>
                ) : (
                  "Verify OTP"
                )}
              </Button>

              <div className="text-center text-sm text-muted-foreground">
                {resendSeconds > 0 ? (
                  <span>Resend OTP in {resendSeconds}s</span>
                ) : (
                  <button
                    type="button"
                    onClick={() => void handleResend()}
                    className="font-semibold text-primary hover:underline"
                  >
                    Resend OTP
                  </button>
                )}
              </div>
            </div>
          )}

          <p className="mt-6 text-center text-sm text-muted-foreground">
            Prefer password?{" "}
            <Link href={`${ROUTES.login}?mode=password`} className="font-semibold text-primary hover:underline">
              Sign in with password
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
