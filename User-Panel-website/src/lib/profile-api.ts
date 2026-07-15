import { authFetch } from "@/lib/api";

export interface ProfileAddress {
  id: string;
  label: string;
  address_line: string;
  latitude: number | null;
  longitude: number | null;
  is_default: boolean;
}

export interface Profile {
  id: string;
  phone: string;
  full_name: string | null;
  email: string | null;
  profile_image_url: string | null;
  gender: string | null;
  emergency_contact_name: string | null;
  emergency_contact_phone: string | null;
  default_pickup_address: string | null;
  referral_code: string | null;
  rating_avg: number;
  addresses: ProfileAddress[];
}

export function getProfile(): Promise<Profile> {
  return authFetch<Profile>("/profile", undefined, "Unable to load profile");
}

export function updateProfile(payload: {
  full_name?: string;
  email?: string;
  gender?: string;
  emergency_contact_name?: string;
  emergency_contact_phone?: string;
  default_pickup_address?: string;
  referral_code?: string;
}): Promise<Profile> {
  return authFetch<Profile>(
    "/profile",
    { method: "PATCH", body: JSON.stringify(payload) },
    "Unable to update profile"
  );
}

export function listAddresses(): Promise<ProfileAddress[]> {
  return authFetch<ProfileAddress[]>("/profile/addresses", undefined, "Unable to load addresses");
}

export function createAddress(payload: {
  label: string;
  address_line: string;
  latitude?: number;
  longitude?: number;
  is_default?: boolean;
}): Promise<ProfileAddress> {
  return authFetch<ProfileAddress>(
    "/profile/addresses",
    { method: "POST", body: JSON.stringify(payload) },
    "Unable to save address"
  );
}

export function deleteAddress(addressId: string): Promise<{ message: string }> {
  return authFetch<{ message: string }>(
    `/profile/addresses/${addressId}`,
    { method: "DELETE" },
    "Unable to delete address"
  );
}

export function logoutAccount(_refreshToken: string): Promise<{ message: string }> {
  return Promise.resolve({ message: "Logged out" });
}

export function deleteAccount(_refreshToken: string): Promise<{ message: string }> {
  return authFetch<{ message: string }>(
    "/auth/me",
    { method: "DELETE" },
    "Unable to delete account"
  );
}
