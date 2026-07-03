import { authFetch } from "@/lib/api";

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
  currency: string;
}

export function estimateFare(payload: {
  vehicle_category_id: string;
  distance_km: number;
  duration_min: number;
}): Promise<FareEstimate> {
  return authFetch<{ vehicle_types: Array<{ vehicle_type_id: string; estimated_fare: number }> }>(
    "/rides/estimate",
    {
      method: "POST",
      body: JSON.stringify({
        pickup_lat: 28.6328,
        pickup_lng: 77.2167,
        dropoff_lat: 28.4595,
        dropoff_lng: 77.0266,
        vehicle_type_id: payload.vehicle_category_id,
      }),
    },
    "Unable to estimate fare"
  ).then((res) => {
    const match = res.vehicle_types.find((v) => v.vehicle_type_id === payload.vehicle_category_id)
      ?? res.vehicle_types[0];
    return {
      category_id: match?.vehicle_type_id ?? payload.vehicle_category_id,
      estimated_fare: match?.estimated_fare ?? 0,
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
