"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import { cn } from "@/lib/utils";

interface VehicleOptionImageProps {
  src: string;
  alt: string;
  fallbackSrc?: string;
  className?: string;
}

/** Loads admin vehicle icons; falls back to local service art if remote fails. */
export function VehicleOptionImage({
  src,
  alt,
  fallbackSrc = "/images/services/car.png",
  className,
}: VehicleOptionImageProps) {
  const [current, setCurrent] = useState(src || fallbackSrc);

  useEffect(() => {
    setCurrent(src || fallbackSrc);
  }, [src, fallbackSrc]);

  return (
    <div className={cn("relative h-10 w-10 shrink-0", className)}>
      <Image
        src={current}
        alt={alt}
        fill
        unoptimized
        sizes="40px"
        className="object-contain"
        onError={() => {
          if (current !== fallbackSrc) setCurrent(fallbackSrc);
        }}
      />
    </div>
  );
}
