import { appSettings as defaultAppSettings } from "@/data/mock-data";
import type { AppSettings } from "@/types";

export const APP_SETTINGS_STORAGE_KEY = "wavego_app_settings";

export function getStoredAppSettings(): AppSettings {
  if (typeof window === "undefined") return defaultAppSettings;

  try {
    const raw = localStorage.getItem(APP_SETTINGS_STORAGE_KEY);
    if (!raw) return defaultAppSettings;

    const stored = JSON.parse(raw) as Partial<AppSettings>;
    return { ...defaultAppSettings, ...stored };
  } catch {
    return defaultAppSettings;
  }
}

export function storeAppSettings(settings: AppSettings) {
  localStorage.setItem(APP_SETTINGS_STORAGE_KEY, JSON.stringify(settings));
}

export function validateAppSettings(settings: AppSettings): { valid: boolean; error?: string } {
  if (!settings.appName.trim()) {
    return { valid: false, error: "App name is required" };
  }
  if (!settings.contactEmail.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(settings.contactEmail)) {
    return { valid: false, error: "Enter a valid contact email" };
  }
  if (!settings.contactPhone.trim()) {
    return { valid: false, error: "Contact phone is required" };
  }

  if (settings.firebaseConfig.trim()) {
    try {
      JSON.parse(settings.firebaseConfig);
    } catch {
      return { valid: false, error: "Firebase configuration must be valid JSON" };
    }
  }

  const total = settings.driverCommission + settings.platformFee;
  if (total !== 100) {
    return {
      valid: false,
      error: `Driver commission and platform fee must add up to 100% (currently ${total}%)`,
    };
  }

  return { valid: true };
}
