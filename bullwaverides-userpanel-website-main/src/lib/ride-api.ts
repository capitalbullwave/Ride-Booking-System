import { apiFetch, authFetch } from "@/lib/api";

export interface Ride {
  id: string;
  pickup_address: string;
  dropoff_address: string;
  status: string;
  fare_estimate: number | null;
  fare_final: number | null;
  cancelled_reason?: string | null;
  created_at: string;
}

interface BackendRide {
  id: string;
  pickup_address: string;
  dropoff_address: string;
  status: string;
  estimated_fare?: number;
  final_fare?: number | null;
  fare_estimate?: number | null;
  fare_final?: number | null;
  cancellation_reason?: string | null;
  created_at: string;
}

interface RideHistoryBackend {
  items: BackendRide[];
  total: number;
  page: number;
  page_size: number;
  total_pages?: number;
  pages?: number;
}

function mapRide(ride: BackendRide): Ride {
  return {
    id: ride.id,
    pickup_address: ride.pickup_address,
    dropoff_address: ride.dropoff_address,
    status: ride.status,
    fare_estimate: ride.fare_estimate ?? ride.estimated_fare ?? null,
    fare_final: ride.fare_final ?? ride.final_fare ?? null,
    cancelled_reason: ride.cancellation_reason ?? null,
    created_at: ride.created_at,
  };
}

export interface RideHistoryResponse {
  items: Ride[];
  total: number;
  page: number;
  page_size: number;
  pages: number;
}

export interface FareEstimate {
  category_id: string;
  estimated_fare: number;
  original_fare?: number | null;
  member_discount?: number;
  discount_percent?: number;
  currency: string;
}

export interface RideDirections {
  pickup_lat: number;
  pickup_lng: number;
  dropoff_lat: number;
  dropoff_lng: number;
  distance_km: number;
  duration_min: number;
}

export async function getRideDirections(
  pickup: string,
  dropoff: string
): Promise<RideDirections> {
  const params = new URLSearchParams({ pickup, dropoff });
  const data = await apiFetch<{
    pickup: { lat: number; lng: number };
    dropoff: { lat: number; lng: number };
    distance_km: number;
    duration_min: number;
  }>(`/public/places/directions?${params.toString()}`, undefined, "Unable to load route");

  return {
    pickup_lat: data.pickup.lat,
    pickup_lng: data.pickup.lng,
    dropoff_lat: data.dropoff.lat,
    dropoff_lng: data.dropoff.lng,
    distance_km: data.distance_km,
    duration_min: data.duration_min,
  };
}

interface VehicleFareQuote {
  vehicle_type_id: string;
  estimated_fare: number;
  original_fare?: number | null;
  member_discount?: number;
  discount_percent?: number;
}

export async function estimateRideFares(payload: {
  pickup_lat: number;
  pickup_lng: number;
  dropoff_lat: number;
  dropoff_lng: number;
}): Promise<{
  discount_percent: number | null;
  quotes: Record<string, VehicleFareQuote>;
}> {
  const res = await authFetch<{
    vehicle_types: VehicleFareQuote[];
    discount_percent?: number | null;
  }>(
    "/rides/estimate",
    {
      method: "POST",
      body: JSON.stringify(payload),
    },
    "Unable to estimate fare"
  );

  const quotes: Record<string, VehicleFareQuote> = {};
  for (const item of res.vehicle_types ?? []) {
    quotes[item.vehicle_type_id] = item;
  }

  return {
    discount_percent: res.discount_percent ?? null,
    quotes,
  };
}

export function estimateFare(payload: {
  vehicle_category_id: string;
  pickup_lat: number;
  pickup_lng: number;
  dropoff_lat: number;
  dropoff_lng: number;
  distance_km?: number;
  duration_min?: number;
}): Promise<FareEstimate> {
  return estimateRideFares({
    pickup_lat: payload.pickup_lat,
    pickup_lng: payload.pickup_lng,
    dropoff_lat: payload.dropoff_lat,
    dropoff_lng: payload.dropoff_lng,
  }).then((res) => {
    const match =
      res.quotes[payload.vehicle_category_id] ??
      Object.values(res.quotes)[0];
    return {
      category_id: match?.vehicle_type_id ?? payload.vehicle_category_id,
      estimated_fare: match?.estimated_fare ?? 0,
      original_fare: match?.original_fare ?? null,
      member_discount: match?.member_discount ?? 0,
      discount_percent: match?.discount_percent ?? res.discount_percent ?? 0,
      currency: "INR",
    };
  });
}

export function bookRide(payload: {
  pickup_address: string;
  dropoff_address: string;
  vehicle_category_id?: string;
}): Promise<Ride> {
  return authFetch<BackendRide>(
    "/book-ride",
    { method: "POST", body: JSON.stringify(payload) },
    "Unable to book ride"
  ).then(mapRide);
}

export function getActiveRide(): Promise<Ride | null> {
  return authFetch<{ active: BackendRide | null }>("/rides", undefined, "Unable to load active ride").then(
    (res) => (res.active ? mapRide(res.active) : null)
  );
}

export function getRideHistory(page = 1, pageSize = 20): Promise<RideHistoryResponse> {
  return authFetch<{ items: BackendRide[]; page: number; page_size: number }>(
    `/rides?page=${page}&page_size=${pageSize}`,
    undefined,
    "Unable to load ride history"
  ).then((res) => ({
    items: res.items.map(mapRide),
    total: res.items.length,
    page: res.page,
    page_size: res.page_size,
    pages: 1,
  }));
}

export function getRide(rideId: string): Promise<Ride> {
  return authFetch<BackendRide>(`/ride/${rideId}`, undefined, "Unable to load ride").then(mapRide);
}

export function getRideStatus(rideId: string): Promise<{ status: string }> {
  return authFetch<BackendRide>(`/ride/${rideId}`, undefined, "Unable to load ride status").then((r) => ({
    status: r.status,
  }));
}

export function cancelRide(rideId: string, reason?: string): Promise<Ride> {
  return authFetch<BackendRide>(
    "/cancel-ride",
    { method: "POST", body: JSON.stringify({ ride_id: rideId, reason: reason || "User cancelled" }) },
    "Unable to cancel ride"
  ).then(mapRide);
}

export function getRideTracking(rideId: string): Promise<Record<string, unknown>> {
  return authFetch<Record<string, unknown>>(`/ride/${rideId}`, undefined, "Unable to load tracking");
}

export function rateRide(
  rideId: string,
  rating: number,
  comment?: string
): Promise<{ ride_id: string; rating: number }> {
  return authFetch<{ ride_id: string; rating: number }>(
    `/ride/${rideId}/rate`,
    {
      method: "POST",
      body: JSON.stringify({ rating, comment: comment ?? null }),
    },
    "Unable to submit rating"
  );
}

export function getNearbyDrivers(): Promise<{ count: number; eta_minutes: number }> {
  return Promise.resolve({ count: 3, eta_minutes: 5 });
}
