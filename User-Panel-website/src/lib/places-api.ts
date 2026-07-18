import { apiFetch } from "@/lib/api";

export interface PlaceSuggestion {
  id: string;
  name: string;
  address: string;
  latitude?: number | null;
  longitude?: number | null;
  source?: string;
}

export interface SelectedPlace {
  label: string;
  latitude?: number;
  longitude?: number;
}

function hasCoordinates(
  place: Pick<PlaceSuggestion, "latitude" | "longitude"> | SelectedPlace
): boolean {
  const lat = "latitude" in place ? place.latitude : undefined;
  const lng = "longitude" in place ? place.longitude : undefined;
  return typeof lat === "number" && typeof lng === "number";
}

export async function searchPlaces(query: string, limit = 8): Promise<PlaceSuggestion[]> {
  const trimmed = query.trim();
  if (trimmed.length < 2) return [];

  const params = new URLSearchParams({
    q: trimmed,
    limit: String(limit),
    country: "in",
  });

  const data = await apiFetch<{ results: PlaceSuggestion[] }>(
    `/public/places/search?${params.toString()}`,
    undefined,
    "Unable to search places"
  );

  return data.results ?? [];
}

export async function getPlaceDetails(placeId: string): Promise<PlaceSuggestion> {
  const params = new URLSearchParams({ place_id: placeId });
  return apiFetch<PlaceSuggestion>(
    `/public/places/details?${params.toString()}`,
    undefined,
    "Unable to load place details"
  );
}

/** Resolve place_id when search results lack lat/lng (same as Flutter). */
export async function resolvePlaceDetails(place: PlaceSuggestion): Promise<SelectedPlace> {
  if (hasCoordinates(place)) {
    return {
      label: place.address || place.name,
      latitude: place.latitude!,
      longitude: place.longitude!,
    };
  }

  const details = await getPlaceDetails(place.id);
  return {
    label: details.address || details.name || place.address || place.name,
    latitude: details.latitude ?? undefined,
    longitude: details.longitude ?? undefined,
  };
}

export async function reverseGeocode(lat: number, lng: number): Promise<SelectedPlace> {
  const params = new URLSearchParams({
    lat: String(lat),
    lng: String(lng),
  });

  try {
    const data = await apiFetch<{
      address: string;
      latitude: number;
      longitude: number;
    }>(`/public/places/reverse?${params.toString()}`, undefined, "Unable to resolve location");

    return {
      label: data.address?.trim() || "Current location",
      latitude: data.latitude ?? lat,
      longitude: data.longitude ?? lng,
    };
  } catch {
    return {
      label: "Current location",
      latitude: lat,
      longitude: lng,
    };
  }
}

export function directionsQuery(place: SelectedPlace): string {
  if (hasCoordinates(place)) {
    return `${place.latitude},${place.longitude}`;
  }
  return place.label;
}
