"use client";

import { useEffect, useRef, useState } from "react";
import { ExternalLink, MapPin } from "lucide-react";
import type { LatLngExpression, Map as LeafletMap } from "leaflet";
import "leaflet/dist/leaflet.css";
import type { RideStop } from "@/types";

type RideRouteMapProps = {
  pickupLocation: string;
  dropLocation: string;
  pickupLat?: number;
  pickupLng?: number;
  dropLat?: number;
  dropLng?: number;
  stops?: RideStop[];
};

function escapeHtml(text: string): string {
  return text
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function hasValidCoords(
  pickupLat?: number,
  pickupLng?: number,
  dropLat?: number,
  dropLng?: number,
): pickupLat is number {
  return (
    pickupLat != null &&
    pickupLng != null &&
    dropLat != null &&
    dropLng != null &&
    Number.isFinite(pickupLat) &&
    Number.isFinite(pickupLng) &&
    Number.isFinite(dropLat) &&
    Number.isFinite(dropLng)
  );
}

function validStops(stops?: RideStop[]): RideStop[] {
  return (stops ?? [])
    .filter(
      (s) =>
        s.address.trim() &&
        Number.isFinite(s.lat) &&
        Number.isFinite(s.lng),
    )
    .slice(0, 3);
}

function buildOpenInMapsUrl(props: RideRouteMapProps): string | null {
  const { pickupLat, pickupLng, dropLat, dropLng, pickupLocation, dropLocation } =
    props;
  const stops = validStops(props.stops);

  if (hasValidCoords(pickupLat, pickupLng, dropLat, dropLng)) {
    const params = new URLSearchParams({
      api: "1",
      origin: `${pickupLat},${pickupLng}`,
      destination: `${dropLat},${dropLng}`,
      travelmode: "driving",
    });
    if (stops.length > 0) {
      params.set(
        "waypoints",
        stops.map((s) => `${s.lat},${s.lng}`).join("|"),
      );
    }
    return `https://www.google.com/maps/dir/?${params.toString()}`;
  }

  if (!pickupLocation.trim() || !dropLocation.trim()) return null;
  const params = new URLSearchParams({
    api: "1",
    origin: pickupLocation,
    destination: dropLocation,
    travelmode: "driving",
  });
  if (stops.length > 0) {
    params.set("waypoints", stops.map((s) => s.address).join("|"));
  }
  return `https://www.google.com/maps/dir/?${params.toString()}`;
}

async function fetchDrivingRoute(
  pickupLat: number,
  pickupLng: number,
  dropLat: number,
  dropLng: number,
  stops: RideStop[] = [],
): Promise<LatLngExpression[] | null> {
  try {
    const points = [
      `${pickupLng},${pickupLat}`,
      ...stops.map((s) => `${s.lng},${s.lat}`),
      `${dropLng},${dropLat}`,
    ];
    const url =
      `https://router.project-osrm.org/route/v1/driving/` +
      points.join(";") +
      `?overview=full&geometries=geojson`;
    const res = await fetch(url);
    if (!res.ok) return null;
    const data = (await res.json()) as {
      routes?: { geometry?: { coordinates?: [number, number][] } }[];
    };
    const coords = data.routes?.[0]?.geometry?.coordinates;
    if (!coords?.length) return null;
    return coords.map(([lng, lat]) => [lat, lng] as LatLngExpression);
  } catch {
    return null;
  }
}

export function RideRouteMap(props: RideRouteMapProps) {
  const {
    pickupLocation,
    dropLocation,
    pickupLat,
    pickupLng,
    dropLat,
    dropLng,
  } = props;
  const stops = validStops(props.stops);
  const containerRef = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<LeafletMap | null>(null);
  const [mapError, setMapError] = useState(false);

  const openUrl = buildOpenInMapsUrl(props);
  const ready = hasValidCoords(pickupLat, pickupLng, dropLat, dropLng);
  const stopsKey = stops.map((s) => `${s.lat},${s.lng}`).join("|");

  useEffect(() => {
    if (!ready || !containerRef.current) return;

    let cancelled = false;

    async function initMap() {
      const L = (await import("leaflet")).default;

      if (cancelled || !containerRef.current) return;

      if (mapRef.current) {
        mapRef.current.remove();
        mapRef.current = null;
      }

      const pickup: LatLngExpression = [pickupLat!, pickupLng!];
      const drop: LatLngExpression = [dropLat!, dropLng!];

      const map = L.map(containerRef.current, {
        scrollWheelZoom: false,
        zoomControl: true,
      });
      mapRef.current = map;

      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution:
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
        maxZoom: 19,
      }).addTo(map);

      const labeledIcon = (label: string, color: string) =>
        L.divIcon({
          className: "",
          iconSize: [72, 36],
          iconAnchor: [36, 36],
          html: `<div style="display:flex;flex-direction:column;align-items:center;gap:2px;">
            <span style="background:${color};color:#fff;font:600 11px/1.2 system-ui,sans-serif;padding:4px 8px;border-radius:999px;white-space:nowrap;box-shadow:0 1px 4px rgba(0,0,0,.25);">${label}</span>
            <span style="width:12px;height:12px;border-radius:50%;background:${color};border:2px solid #fff;box-shadow:0 1px 3px rgba(0,0,0,.35);"></span>
          </div>`,
        });

      const pickupMarker = L.marker(pickup, {
        icon: labeledIcon("Pickup", "#16a34a"),
      }).addTo(map);
      pickupMarker.bindPopup(
        `<strong>Pickup</strong><br/>${escapeHtml(pickupLocation)}`,
      );

      stops.forEach((stop, index) => {
        const marker = L.marker([stop.lat, stop.lng], {
          icon: labeledIcon(`Stop ${index + 1}`, "#7c3aed"),
        }).addTo(map);
        marker.bindPopup(
          `<strong>Stop ${index + 1}</strong><br/>${escapeHtml(stop.address)}`,
        );
      });

      const dropMarker = L.marker(drop, {
        icon: labeledIcon("Drop", "#dc2626"),
      }).addTo(map);
      dropMarker.bindPopup(
        `<strong>Drop</strong><br/>${escapeHtml(dropLocation)}`,
      );

      const routeCoords =
        (await fetchDrivingRoute(
          pickupLat!,
          pickupLng!,
          dropLat!,
          dropLng!,
          stops,
        )) ??
        [
          pickup,
          ...stops.map((s) => [s.lat, s.lng] as LatLngExpression),
          drop,
        ];

      if (cancelled) return;

      const routeLine = L.polyline(routeCoords, {
        color: "#6d28d9",
        weight: 4,
        opacity: 0.85,
      }).addTo(map);

      map.fitBounds(routeLine.getBounds(), { padding: [36, 36] });
      requestAnimationFrame(() => map.invalidateSize());
    }

    initMap().catch(() => {
      if (!cancelled) setMapError(true);
    });

    return () => {
      cancelled = true;
      if (mapRef.current) {
        mapRef.current.remove();
        mapRef.current = null;
      }
    };
  }, [
    ready,
    pickupLat,
    pickupLng,
    dropLat,
    dropLng,
    pickupLocation,
    dropLocation,
    stopsKey,
  ]);

  if (!ready) {
    return (
      <div className="flex h-72 items-center justify-center rounded-lg border-2 border-dashed bg-muted/50">
        <div className="px-4 text-center">
          <MapPin className="mx-auto h-10 w-10 text-primary/50" />
          <p className="mt-2 text-sm font-medium">Location unavailable</p>
          <p className="text-xs text-muted-foreground">
            Pickup or drop coordinates are missing for this ride.
          </p>
          {(pickupLocation || dropLocation) && (
            <p className="mt-2 text-xs text-muted-foreground">
              {pickupLocation}
              {pickupLocation && dropLocation ? " → " : ""}
              {dropLocation}
            </p>
          )}
        </div>
      </div>
    );
  }

  if (mapError) {
    return (
      <div className="flex h-72 flex-col items-center justify-center gap-3 rounded-lg border bg-muted/50 px-4 text-center">
        <MapPin className="h-10 w-10 text-primary/50" />
        <p className="text-sm font-medium">Unable to load map</p>
        {openUrl && (
          <a
            href={openUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1 text-sm font-medium text-primary hover:underline"
          >
            Open route in Google Maps
            <ExternalLink className="h-3.5 w-3.5" />
          </a>
        )}
      </div>
    );
  }

  const routeHint = [
    pickupLocation,
    ...stops.map((s, i) => `Stop ${i + 1}: ${s.address}`),
    dropLocation,
  ]
    .filter(Boolean)
    .join(" → ");

  return (
    <div className="overflow-hidden rounded-lg border">
      <div ref={containerRef} className="h-72 w-full z-0" />
      <div className="flex flex-col gap-2 border-t bg-muted/30 px-3 py-2 sm:flex-row sm:items-center sm:justify-between">
        <p className="text-xs text-muted-foreground line-clamp-2">
          <span className="font-medium text-emerald-600">Pickup</span>
          {stops.length > 0 && (
            <>
              <span className="mx-1.5 text-muted-foreground/60">→</span>
              <span className="font-medium text-violet-600">
                {stops.length} stop{stops.length > 1 ? "s" : ""}
              </span>
            </>
          )}
          <span className="mx-1.5 text-muted-foreground/60">→</span>
          <span className="font-medium text-red-600">Drop</span>
          <span className="sr-only">{routeHint}</span>
        </p>
        {openUrl && (
          <a
            href={openUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex shrink-0 items-center gap-1 text-xs font-medium text-primary hover:underline"
          >
            Open in Google Maps
            <ExternalLink className="h-3 w-3" />
          </a>
        )}
      </div>
    </div>
  );
}
