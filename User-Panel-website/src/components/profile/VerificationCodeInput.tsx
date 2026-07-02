"use client";

import { useEffect, useRef, useState } from "react";
import { cn } from "@/lib/utils";

interface VerificationCodeInputProps {
  length?: number;
  value: string;
  onChange: (value: string) => void;
}

export function VerificationCodeInput({
  length = 4,
  value,
  onChange,
}: VerificationCodeInputProps) {
  const [digits, setDigits] = useState<string[]>(new Array(length).fill(""));
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  useEffect(() => {
    const next = new Array(length).fill("");
    value.split("").forEach((char, index) => {
      if (index < length) next[index] = char;
    });
    setDigits(next);
  }, [value, length]);

  const focusInput = (index: number) => {
    inputRefs.current[index]?.focus();
  };

  const updateDigits = (next: string[]) => {
    setDigits(next);
    onChange(next.join(""));
  };

  const handleChange = (index: number, e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value.replace(/\D/g, "");
    if (!val) return;

    const next = [...digits];
    next[index] = val.slice(-1);
    updateDigits(next);

    if (index < length - 1) focusInput(index + 1);
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Backspace") {
      if (digits[index] === "" && index > 0) {
        focusInput(index - 1);
      } else {
        const next = [...digits];
        next[index] = "";
        updateDigits(next);
      }
    } else if (e.key === "ArrowLeft" && index > 0) {
      focusInput(index - 1);
    } else if (e.key === "ArrowRight" && index < length - 1) {
      focusInput(index + 1);
    }
  };

  const handlePaste = (e: React.ClipboardEvent<HTMLInputElement>) => {
    e.preventDefault();
    const pasted = e.clipboardData.getData("text/plain").replace(/\D/g, "").slice(0, length);
    if (!pasted) return;

    const next = new Array(length).fill("");
    pasted.split("").forEach((char, i) => {
      next[i] = char;
    });
    updateDigits(next);
    focusInput(Math.min(pasted.length, length - 1));
  };

  return (
    <div className="flex gap-3">
      {digits.map((digit, index) => (
        <input
          key={index}
          ref={(el) => {
            inputRefs.current[index] = el;
          }}
          type="text"
          inputMode="numeric"
          maxLength={1}
          value={digit}
          onChange={(e) => handleChange(index, e)}
          onKeyDown={(e) => handleKeyDown(index, e)}
          onPaste={handlePaste}
          onFocus={(e) => e.target.select()}
          className={cn(
            "h-14 w-14 rounded-xl text-center text-lg font-semibold text-foreground transition-all focus:outline-none focus:ring-2 focus:ring-primary/20",
            digit
              ? "border border-primary bg-card"
              : "border border-transparent bg-muted focus:border-primary"
          )}
        />
      ))}
    </div>
  );
}
