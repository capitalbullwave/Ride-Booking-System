"use client";

import { CountryCodeSelector } from "@/components/auth/CountryCodeSelector";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  defaultCountry,
  formatPhoneDisplay,
  getPhonePlaceholder,
  isValidPhoneNumber,
  sanitizePhoneInput,
  type Country,
} from "@/lib/countries";
import { cn } from "@/lib/utils";

interface PhoneInputProps {
  country: Country;
  phone: string;
  onCountryChange: (country: Country) => void;
  onPhoneChange: (phone: string) => void;
  error?: string;
  disabled?: boolean;
}

export function PhoneInput({
  country,
  phone,
  onCountryChange,
  onPhoneChange,
  error,
  disabled,
}: PhoneInputProps) {
  return (
    <div className="space-y-2">
      <Label htmlFor="phone-input">Mobile number</Label>
      <div className="flex gap-2">
        <CountryCodeSelector
          value={country}
          onChange={(selected) => {
            onCountryChange(selected);
            onPhoneChange(sanitizePhoneInput(phone, selected));
          }}
        />
        <Input
          id="phone-input"
          type="tel"
          inputMode="numeric"
          autoComplete="tel-national"
          placeholder={getPhonePlaceholder(country)}
          value={formatPhoneDisplay(phone, country)}
          disabled={disabled}
          onChange={(e) => onPhoneChange(sanitizePhoneInput(e.target.value, country))}
          className={cn(
            "h-12 flex-1 rounded-[16px] text-base",
            error && "border-destructive focus-visible:ring-destructive/30"
          )}
        />
      </div>
      {error ? <p className="text-sm text-destructive">{error}</p> : null}
    </div>
  );
}

export function toE164Phone(country: Country, phoneDigits: string): string {
  if (!isValidPhoneNumber(phoneDigits, country)) {
    throw new Error("Please enter a valid mobile number");
  }
  return `${country.dialCode}${phoneDigits}`;
}

export { defaultCountry, isValidPhoneNumber };
