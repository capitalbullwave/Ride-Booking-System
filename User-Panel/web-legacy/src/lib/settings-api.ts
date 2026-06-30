import { apiFetch } from "@/lib/api";

export function getPrivacyPolicy(): Promise<{ content: string }> {
  return apiFetch<{ content: string }>("/api/v1/public/privacy-policy", undefined, "Unable to load privacy policy");
}

export function getTermsAndConditions(): Promise<{ content: string }> {
  return apiFetch<{ content: string }>("/api/v1/public/terms", undefined, "Unable to load terms");
}

export function getAboutUs(): Promise<Record<string, string>> {
  return apiFetch<Record<string, string>>("/api/v1/public/about", undefined, "Unable to load about info");
}
