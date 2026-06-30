"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { SettingsHeader } from "@/components/layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { CountryCodeSelector } from "@/components/auth/CountryCodeSelector";
import { ROUTES } from "@/constants/routes";
import {
  defaultCountry,
  formatPhoneDisplay,
  getPhonePlaceholder,
  isValidPhoneNumber,
  parsePhoneDisplay,
  sanitizePhoneInput,
  type Country,
} from "@/lib/countries";

export function PhoneSettingsView() {
  const router = useRouter();
  const [country, setCountry] = useState<Country>(defaultCountry);
  const [phoneNumber, setPhoneNumber] = useState("9876543210");
  const [error, setError] = useState("");

  const handleUpdate = (e: React.FormEvent) => {
    e.preventDefault();

    if (!isValidPhoneNumber(phoneNumber, country)) {
      setError("Please enter a valid phone number");
      return;
    }

    setError("");
    const contact = `${country.dialCode} ${formatPhoneDisplay(phoneNumber, country)}`;
    router.push(
      `${ROUTES.profilePhoneVerify}?contact=${encodeURIComponent(contact)}`
    );
  };

  const handleCountryChange = (selected: Country) => {
    setCountry(selected);
    setPhoneNumber((prev) => sanitizePhoneInput(prev, selected));
    setError("");
  };

  const handlePhoneChange = (value: string) => {
    setPhoneNumber(parsePhoneDisplay(value, country));
    if (error) setError("");
  };

  return (
    <div className="flex min-h-screen flex-col bg-background pb-8">
      <SettingsHeader />

      <div className="w-full flex-1 px-6 py-6 md:px-12 lg:px-24">
        <div className="max-w-md">
          <h1 className="font-heading text-3xl font-bold text-foreground">Phone number</h1>
          <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
            You&apos;ll use this number to get notifications, sign in, and recover your account.
          </p>

          <form onSubmit={handleUpdate} className="mt-10">
          <div className="flex flex-col gap-3">
            <Label htmlFor="phone" className="text-sm font-semibold text-foreground">
              Phone number
            </Label>
            <div className="flex gap-3">
              <CountryCodeSelector value={country} onChange={handleCountryChange} />
              <div
                className={`flex h-12 min-w-0 flex-1 items-center rounded-[14px] border bg-muted px-4 focus-within:bg-card focus-within:ring-2 ${
                  error
                    ? "border-destructive focus-within:ring-destructive/20"
                    : "border-border focus-within:ring-primary/20"
                }`}
              >
                <span className="shrink-0 text-base text-foreground">{country.dialCode}</span>
                <Input
                  id="phone"
                  type="tel"
                  inputMode="numeric"
                  value={formatPhoneDisplay(phoneNumber, country)}
                  onChange={(e) => handlePhoneChange(e.target.value)}
                  className="h-full flex-1 border-0 bg-transparent px-2 text-base shadow-none focus-visible:ring-0"
                  placeholder={getPhonePlaceholder(country)}
                  maxLength={country.maxLength + 1}
                  aria-invalid={!!error}
                />
              </div>
            </div>
            <p className="text-xs text-muted-foreground">
              A verification code will be sent to this number
            </p>
            {error && <p className="text-xs font-medium text-destructive">{error}</p>}
          </div>

          <Button
            type="submit"
            className="mt-8 h-12 rounded-[14px] px-8 font-semibold"
            disabled={!isValidPhoneNumber(phoneNumber, country)}
          >
            Update
          </Button>
        </form>
        </div>
      </div>
    </div>
  );
}
