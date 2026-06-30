"use client";

import type { AmbulanceType } from "@/types/ambulance";
import { Stethoscope, HeartPulse, Activity, Plane } from "lucide-react";

interface AmbulanceCardProps {
  type: AmbulanceType;
  isSelected: boolean;
  onSelect: (type: AmbulanceType) => void;
}

const IconMap: Record<string, React.ElementType> = {
  Stethoscope,
  HeartPulse,
  Activity,
  Plane,
};

export function AmbulanceCard({ type, isSelected, onSelect }: AmbulanceCardProps) {
  const IconComponent = IconMap[type.icon] || Stethoscope;

  return (
    <div
      onClick={() => onSelect(type)}
      className={`group relative flex cursor-pointer flex-col gap-3 rounded-[20px] border-2 p-5 transition-all duration-300 hover:shadow-md ${
        isSelected
          ? "border-[#D66B6B] bg-[#D66B6B]/5 shadow-sm"
          : "border-border bg-white hover:border-[#D66B6B]/40"
      }`}
    >
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className={`flex h-12 w-12 items-center justify-center rounded-xl transition-colors ${
            isSelected ? "bg-[#D66B6B] text-white" : "bg-muted text-muted-foreground group-hover:bg-[#D66B6B]/20 group-hover:text-[#D66B6B]"
          }`}>
            <IconComponent className="h-6 w-6" />
          </div>
          <div>
            <h3 className="font-heading font-bold text-foreground">{type.name}</h3>
            <p className="text-xs font-semibold text-[#D66B6B]">ETA: {type.eta}</p>
          </div>
        </div>
        <div className="text-right">
          <p className="text-sm font-bold text-foreground">{type.price}</p>
          <p className="text-[10px] text-muted-foreground">Starting from</p>
        </div>
      </div>
      <p className="text-sm text-muted-foreground">{type.description}</p>
      
      {/* Selected Indicator */}
      {isSelected && (
        <div className="absolute right-4 top-4 h-3 w-3 rounded-full bg-[#D66B6B] shadow-[0_0_0_4px_rgba(214,107,107,0.2)]" />
      )}
    </div>
  );
}
