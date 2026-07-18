/** Intermediate stops between pickup and drop — same limit as Flutter app. */
export const MAX_STOPS = 3;

export interface TripStop {
  label: string;
  latitude?: number;
  longitude?: number;
}

export function filledStops(stops: TripStop[]): TripStop[] {
  return stops
    .filter((s) => s.label.trim().length > 0)
    .slice(0, MAX_STOPS);
}

export function canAddStop(stops: TripStop[]): boolean {
  return filledStops(stops).length < MAX_STOPS;
}

export function writeStopsToParams(params: URLSearchParams, stops: TripStop[]) {
  for (let i = 0; i < MAX_STOPS; i += 1) {
    params.delete(`s${i}`);
    params.delete(`s${i}lat`);
    params.delete(`s${i}lng`);
  }

  filledStops(stops).forEach((stop, i) => {
    params.set(`s${i}`, stop.label);
    if (stop.latitude != null) params.set(`s${i}lat`, String(stop.latitude));
    if (stop.longitude != null) params.set(`s${i}lng`, String(stop.longitude));
  });
}

export function parseStopsFromParams(searchParams: {
  get(name: string): string | null;
}): TripStop[] {
  const stops: TripStop[] = [];
  for (let i = 0; i < MAX_STOPS; i += 1) {
    const label = searchParams.get(`s${i}`);
    if (!label?.trim()) continue;
    const latRaw = searchParams.get(`s${i}lat`);
    const lngRaw = searchParams.get(`s${i}lng`);
    const latitude = latRaw != null && latRaw !== "" ? Number(latRaw) : undefined;
    const longitude = lngRaw != null && lngRaw !== "" ? Number(lngRaw) : undefined;
    stops.push({
      label: label.trim(),
      latitude: Number.isFinite(latitude) ? latitude : undefined,
      longitude: Number.isFinite(longitude) ? longitude : undefined,
    });
  }
  return stops;
}

export function stopsToApiPayload(stops: TripStop[]) {
  return filledStops(stops)
    .filter((s) => s.latitude != null && s.longitude != null)
    .map((s, i) => ({
      address: s.label,
      lat: s.latitude!,
      lng: s.longitude!,
      sequence: i + 1,
    }));
}

export function stopsToWaypointsQuery(stops: TripStop[]): string | undefined {
  const parts = filledStops(stops)
    .filter((s) => s.latitude != null && s.longitude != null)
    .map((s) => `${s.latitude},${s.longitude}`);
  return parts.length > 0 ? parts.join("|") : undefined;
}
