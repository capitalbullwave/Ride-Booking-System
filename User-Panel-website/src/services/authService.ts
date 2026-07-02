import {
  signInWithPhoneNumber,
  type ConfirmationResult,
  type RecaptchaVerifier,
} from "firebase/auth";
import { getFirebaseAuth } from "@/firebase/firebase";
import { apiFetch } from "@/lib/api";

export interface FirebaseAuthResponse {
  access_token: string;
  refresh_token?: string;
  token_type: string;
  user: {
    id?: string;
    phone: string;
    name?: string | null;
    email?: string | null;
  };
}

const FIREBASE_ERROR_MESSAGES: Record<string, string> = {
  "auth/invalid-phone-number": "Invalid phone number. Check the number and country code.",
  "auth/missing-phone-number": "Please enter your mobile number.",
  "auth/too-many-requests": "Too many attempts. Please wait and try again later.",
  "auth/quota-exceeded": "SMS quota exceeded. Try again later.",
  "auth/captcha-check-failed": "reCAPTCHA verification failed. Refresh and try again.",
  "auth/invalid-verification-code": "Invalid OTP. Please check and try again.",
  "auth/code-expired": "OTP expired. Request a new code.",
  "auth/session-expired": "Session expired. Request a new OTP.",
  "auth/network-request-failed": "Network error. Check your connection and try again.",
  "auth/internal-error": "Authentication service error. Please try again.",
  "auth/user-disabled": "This account has been disabled.",
};

export function mapFirebaseError(error: unknown): string {
  if (error && typeof error === "object" && "code" in error) {
    const code = String((error as { code: string }).code);
    if (FIREBASE_ERROR_MESSAGES[code]) {
      return FIREBASE_ERROR_MESSAGES[code];
    }
  }
  if (error instanceof Error && error.message) {
    return error.message;
  }
  return "Something went wrong. Please try again.";
}

/** Send real SMS OTP via Firebase Phone Authentication. */
export async function sendPhoneOtp(
  e164Phone: string,
  recaptchaVerifier: RecaptchaVerifier
): Promise<ConfirmationResult> {
  const auth = getFirebaseAuth();
  try {
    await recaptchaVerifier.render();
  } catch {
    // Already rendered — safe to continue
  }
  return signInWithPhoneNumber(auth, e164Phone, recaptchaVerifier);
}

/** Verify the 6-digit SMS code with Firebase. */
export async function verifyPhoneOtp(
  confirmation: ConfirmationResult,
  otp: string
): Promise<string> {
  const credential = await confirmation.confirm(otp);
  const idToken = await credential.user.getIdToken(true);
  return idToken;
}

/** Exchange Firebase ID token for application JWT from FastAPI. */
export function loginWithFirebaseToken(firebaseToken: string): Promise<FirebaseAuthResponse> {
  return apiFetch<FirebaseAuthResponse>(
    "/api/auth/firebase-login",
    {
      method: "POST",
      body: JSON.stringify({ firebase_token: firebaseToken }),
    },
    "Unable to sign in. Please try again."
  );
}
