import type { Country } from "@/types/country";

/** Normalize phone to E.164 format for Ride-Booking backend. */
export function normalizePhone(dialCode: string, localNumber: string): string {
  const digits = localNumber.replace(/\D/g, "");
  const code = dialCode.startsWith("+") ? dialCode : `+${dialCode.replace(/\D/g, "")}`;
  if (code === "+91" && digits.length === 10) return `+91${digits}`;
  if (digits.startsWith("91") && digits.length === 12) return `+${digits}`;
  return `${code}${digits}`;
}

export function toE164FromParts(dialCode: string, localNumber: string): string {
  return normalizePhone(dialCode, localNumber);
}

export function sanitizePhoneInput(value: string, country: Country): string {
  return value.replace(/\D/g, "").slice(0, country.maxLength);
}

export function isValidPhoneNumber(value: string, country: Country): boolean {
  const length = value.length;
  return length >= country.minLength && length <= country.maxLength;
}

export function getPhonePlaceholder(country: Country): string {
  const digits = "0".repeat(country.maxLength);
  if (country.maxLength <= 4) return digits;
  if (country.maxLength <= 8) {
    const mid = Math.ceil(country.maxLength / 2);
    return `${digits.slice(0, mid)} ${digits.slice(mid)}`;
  }
  const first = Math.floor(country.maxLength / 2);
  return `${digits.slice(0, first)} ${digits.slice(first)}`;
}

export function formatPhoneDisplay(value: string, country: Country): string {
  const digits = sanitizePhoneInput(value, country);
  if (!digits) return "";

  if (country.maxLength <= 8) {
    const mid = Math.ceil(
      digits.length > country.maxLength / 2 ? country.maxLength / 2 : digits.length / 2
    );
    if (digits.length <= mid) return digits;
    return `${digits.slice(0, mid)} ${digits.slice(mid)}`;
  }

  const splitAt = country.code === "IN" ? 5 : Math.floor(country.maxLength / 2);
  if (digits.length <= splitAt) return digits;
  return `${digits.slice(0, splitAt)} ${digits.slice(splitAt)}`;
}

export function parsePhoneDisplay(value: string, country: Country): string {
  return sanitizePhoneInput(value, country);
}
