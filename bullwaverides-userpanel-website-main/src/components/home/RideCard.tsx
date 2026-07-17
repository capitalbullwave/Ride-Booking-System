"use client";

import { MapPin, Clock } from "lucide-react";

interface RideCardProps {
  title: string;
  address: string;
  date: string;
  price: string;
  status?: string;
}

export function RideCard({ title, address, date, price, status }: RideCardProps) {
  return (
    <div className="flex w-full min-w-[280px] snap-center flex-col gap-3 rounded-[18px] border border-border bg-card p-4 shadow-sm transition-all hover:shadow-md">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-full bg-muted">
            <MapPin className="h-4 w-4 text-primary" />
          </div>
          <h3 className="font-semibold text-foreground">{title}</h3>
        </div>
        <span className="font-bold text-foreground">{price}</span>
      </div>
      
      <p className="text-sm text-muted-foreground line-clamp-1">{address}</p>
      
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
          <Clock className="h-3.5 w-3.5" />
          <span>{date}</span>
        </div>
        
        {status && (
          <div className={`rounded-full px-2.5 py-1 text-[10px] font-bold ${
            status === "Completed" ? "bg-[#34C759]/10 text-[#34C759]" : "bg-destructive/10 text-destructive"
          }`}>
            {status}
          </div>
        )}
      </div>
    </div>
  );
}
