"use client";

import type { Hospital } from "@/types/ambulance";
import { MapPin, Star, Phone, CheckCircle2, XCircle } from "lucide-react";

interface HospitalCardProps {
  hospital: Hospital;
  onSelect: (hospital: Hospital) => void;
}

export function HospitalCard({ hospital, onSelect }: HospitalCardProps) {
  return (
    <div className="flex flex-col gap-3 rounded-[20px] border border-border bg-white p-5 shadow-sm transition-all hover:shadow-md">
      <div className="flex justify-between items-start">
        <div>
          <h3 className="font-heading font-bold text-foreground text-base leading-tight mb-1">{hospital.name}</h3>
          <p className="text-xs text-muted-foreground line-clamp-1">{hospital.address}</p>
        </div>
        <div className="flex items-center gap-1 rounded-full bg-secondary/20 px-2 py-1 text-xs font-bold text-primary">
          <Star className="h-3 w-3 fill-primary" />
          {hospital.rating}
        </div>
      </div>

      <div className="flex items-center gap-4 text-xs font-medium text-muted-foreground mt-1">
        <div className="flex items-center gap-1">
          <MapPin className="h-3 w-3 text-[#D66B6B]" />
          {hospital.distance} away
        </div>
        <div className="flex items-center gap-1">
          <div className="h-2 w-2 rounded-full bg-primary" />
          {hospital.type}
        </div>
      </div>

      <div className="flex items-center gap-4 text-xs">
        <div className={`flex items-center gap-1 ${hospital.emergencyAvailable ? "text-success" : "text-destructive"}`}>
          {hospital.emergencyAvailable ? <CheckCircle2 className="h-3 w-3" /> : <XCircle className="h-3 w-3" />}
          ER Dept
        </div>
        <div className={`flex items-center gap-1 ${hospital.icuAvailable ? "text-success" : "text-destructive"}`}>
          {hospital.icuAvailable ? <CheckCircle2 className="h-3 w-3" /> : <XCircle className="h-3 w-3" />}
          ICU Available
        </div>
      </div>

      <div className="mt-2 flex items-center gap-3">
        <button className="flex h-10 w-10 shrink-0 items-center justify-center rounded-[12px] bg-muted text-foreground transition-colors hover:bg-muted/80">
          <Phone className="h-4 w-4" />
        </button>
        <button
          onClick={() => onSelect(hospital)}
          className="flex-1 rounded-[12px] bg-primary py-2.5 font-semibold text-white transition-colors hover:bg-primary/90 active:scale-95"
        >
          Select Hospital
        </button>
      </div>
    </div>
  );
}
