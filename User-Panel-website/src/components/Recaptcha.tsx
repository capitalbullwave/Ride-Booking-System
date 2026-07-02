"use client";

import { useEffect, useRef } from "react";
import { RecaptchaVerifier } from "firebase/auth";
import { getFirebaseAuth } from "@/firebase/firebase";

interface RecaptchaProps {
  onVerifierReady: (verifier: RecaptchaVerifier) => void;
  onError?: (message: string) => void;
}

/**
 * Invisible reCAPTCHA container required by Firebase Phone Auth.
 * Mount once per page and reuse the verifier instance.
 */
export function Recaptcha({ onVerifierReady, onError }: RecaptchaProps) {
  const verifierRef = useRef<RecaptchaVerifier | null>(null);
  const initialized = useRef(false);

  useEffect(() => {
    if (initialized.current) return;
    initialized.current = true;

    try {
      const auth = getFirebaseAuth();
      const verifier = new RecaptchaVerifier(auth, "recaptcha-container", {
        size: "invisible",
        callback: () => {
          // reCAPTCHA solved — Firebase proceeds with SMS
        },
        "expired-callback": () => {
          onError?.("reCAPTCHA expired. Please try again.");
        },
      });
      verifierRef.current = verifier;
      onVerifierReady(verifier);
    } catch (error) {
      onError?.(error instanceof Error ? error.message : "Failed to initialize reCAPTCHA");
    }

    return () => {
      verifierRef.current?.clear();
      verifierRef.current = null;
      initialized.current = false;
    };
  }, [onVerifierReady, onError]);

  return <div id="recaptcha-container" className="hidden" aria-hidden="true" />;
}
