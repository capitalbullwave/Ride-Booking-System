import { authFetch, apiFetch } from "@/lib/api";

export interface VehicleCategory {
  id: string;
  slug: string;
  name: string;
  description: string | null;
  base_fare: number;
  per_km_rate: number;
  included_distance_km?: number;
  included_hours?: number;
  per_hour_rate?: number;
  icon_url: string | null;
  service_group?: string;
}

export interface HomeBanner {
  id: string;
  title: string;
  subtitle: string | null;
  image_url: string | null;
  cta_label: string | null;
  cta_url: string | null;
  discount_percent: number | null;
}

export interface HomeOffer {
  code: string;
  title: string;
  description: string | null;
  discount_percent: number | null;
}

export interface RideSummary {
  id: string;
  pickup_address: string;
  dropoff_address: string;
  status: string;
  fare_estimate: number | null;
  created_at: string;
}

export interface HomeDashboard {
  greeting_name: string;
  vehicle_categories: VehicleCategory[];
  rental_categories?: VehicleCategory[];
  offers: HomeOffer[];
  banners: HomeBanner[];
  nearby_drivers_count: number;
  recent_rides: RideSummary[];
  active_ride: RideSummary | null;
}

export function getHomeDashboard(): Promise<HomeDashboard> {
  return authFetch<HomeDashboard>("/dashboard", undefined, "Unable to load home data");
}

export function getVehicleCategories(serviceGroup?: "ride" | "rental"): Promise<VehicleCategory[]> {
  const query = serviceGroup ? `?service_group=${serviceGroup}` : "";
  return apiFetch<VehicleCategory[]>(
    `/api/v1/common/vehicle-types${query}`,
    undefined,
    "Unable to load vehicles"
  );
}

export function getRentalCategories(): Promise<VehicleCategory[]> {
  return apiFetch<VehicleCategory[]>(
    "/api/v1/common/rental-categories",
    undefined,
    "Unable to load rental vehicles"
  );
}

export function getBanners(): Promise<HomeBanner[]> {
  return apiFetch<HomeBanner[]>("/api/v1/common/banners", undefined, "Unable to load banners");
}
