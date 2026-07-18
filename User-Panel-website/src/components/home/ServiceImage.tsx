"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import { cn } from "@/lib/utils";

interface ServiceImageProps {
  src: string;
  alt: string;
  className?: string;
  imageClassName?: string;
  fallbackSrc?: string;
}

export function ServiceImage({
  src,
  alt,
  className,
  imageClassName,
  fallbackSrc = "/images/services/car.png",
}: ServiceImageProps) {
  const [current, setCurrent] = useState(src || fallbackSrc);

  useEffect(() => {
    setCurrent(src || fallbackSrc);
  }, [src, fallbackSrc]);

  return (
    <div className={cn("relative h-full w-full", className)}>
      <Image
        src={current}
        alt={alt}
        fill
        unoptimized
        sizes="112px"
        className={cn("object-contain p-1", imageClassName)}
        onError={() => {
          if (current !== fallbackSrc) setCurrent(fallbackSrc);
        }}
      />
    </div>
  );
}
