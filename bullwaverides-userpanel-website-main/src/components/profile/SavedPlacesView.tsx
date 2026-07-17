"use client";

import { useEffect, useState } from "react";
import { Briefcase, Home, Loader2, MapPin, Plane } from "lucide-react";
import { InfoPageLayout } from "@/components/layout";
import { listAddresses, type ProfileAddress } from "@/lib/profile-api";

const iconForLabel = (label: string) => {
  const lower = label.toLowerCase();
  if (lower.includes("home")) return Home;
  if (lower.includes("office") || lower.includes("work")) return Briefcase;
  if (lower.includes("airport")) return Plane;
  return MapPin;
};

export function SavedPlacesView() {
  const [addresses, setAddresses] = useState<ProfileAddress[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const rows = await listAddresses();
        setAddresses(rows);
      } finally {
        setIsLoading(false);
      }
    }
    void load();
  }, []);

  return (
    <InfoPageLayout title="Saved Places">
      <p className="mb-6 text-sm text-muted-foreground">
        Save locations you use often for faster booking.
      </p>
      {isLoading ? (
        <div className="flex justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      ) : addresses.length > 0 ? (
        <div className="flex flex-col gap-3">
          {addresses.map((place) => {
            const Icon = iconForLabel(place.label);
            return (
              <div
                key={place.id}
                className="flex items-center gap-4 rounded-[20px] border border-border bg-card p-4 text-left shadow-sm"
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-[14px] bg-muted text-muted-foreground">
                  <Icon className="h-5 w-5" />
                </div>
                <div className="flex-1">
                  <p className="font-semibold text-foreground">
                    {place.label}
                    {place.is_default ? (
                      <span className="ml-2 text-xs font-medium text-primary">Default</span>
                    ) : null}
                  </p>
                  <p className="text-sm text-muted-foreground">{place.address_line}</p>
                </div>
                <MapPin className="h-5 w-5 text-muted-foreground/50" />
              </div>
            );
          })}
        </div>
      ) : (
        <p className="text-sm text-muted-foreground">No saved places yet. Add addresses from your profile settings.</p>
      )}
    </InfoPageLayout>
  );
}
