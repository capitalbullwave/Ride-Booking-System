"use client";

import Image from "next/image";
import { useEffect, useState } from "react";
import { cn } from "@/lib/utils";

interface Slide {
  src: string;
  alt: string;
}

interface LandingHeroSliderProps {
  slides: readonly Slide[];
}

const INTERVAL_MS = 4500;

function getOffset(index: number, active: number, length: number) {
  let offset = index - active;
  if (offset > length / 2) offset -= length;
  if (offset < -length / 2) offset += length;
  return offset;
}

export function LandingHeroSlider({ slides }: LandingHeroSliderProps) {
  const [active, setActive] = useState(0);

  useEffect(() => {
    if (slides.length <= 1) return;
    const timer = setInterval(() => {
      setActive((current) => (current + 1) % slides.length);
    }, INTERVAL_MS);
    return () => clearInterval(timer);
  }, [slides.length]);

  return (
    <div className="relative w-full select-none">
      <div className="relative flex h-[340px] items-center justify-center sm:h-[400px] md:h-[480px] lg:h-[560px]">
        {slides.map((slide, index) => {
          const offset = getOffset(index, active, slides.length);
          const absOffset = Math.abs(offset);
          if (absOffset > 1) return null;

          const isActive = offset === 0;
          const scale = isActive ? 1 : 0.86;
          const shift = offset * 30;

          return (
            <button
              key={slide.src}
              type="button"
              aria-label={isActive ? slide.alt : `View ${slide.alt}`}
              onClick={() => setActive(index)}
              className={cn(
                "absolute top-1/2 left-1/2 w-[min(95%,440px)] max-w-full transition-all duration-700 ease-[cubic-bezier(0.4,0,0.2,1)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/40",
                !isActive && "cursor-pointer",
              )}
              style={{
                transform: `translate(calc(-50% + ${shift}%), -50%) scale(${scale})`,
                zIndex: 30 - absOffset * 10,
                opacity: isActive ? 1 : 0.88,
              }}
            >
              <div
                className={cn(
                  "relative aspect-[4/3] w-full overflow-hidden rounded-3xl bg-muted",
                  isActive
                    ? "shadow-[0_24px_48px_-12px_rgba(49,82,110,0.3)]"
                    : "shadow-[0_12px_28px_-8px_rgba(49,82,110,0.2)]",
                )}
              >
                <Image
                  src={slide.src}
                  alt={slide.alt}
                  fill
                  sizes="(max-width: 768px) 95vw, 440px"
                  priority={index === 0}
                  className="object-cover object-center"
                />
                {isActive && (
                  <div className="pointer-events-none absolute inset-0 bg-gradient-to-t from-black/20 via-transparent to-transparent" />
                )}
              </div>
            </button>
          );
        })}
      </div>

      <div className="mt-4 flex justify-center gap-2 md:mt-6">
        {slides.map((slide, index) => (
          <button
            key={slide.src}
            type="button"
            aria-label={`Go to slide ${index + 1}`}
            onClick={() => setActive(index)}
            className={cn(
              "rounded-full transition-all duration-300",
              index === active
                ? "h-2 w-7 bg-primary"
                : "h-2 w-2 bg-primary/25 hover:bg-primary/45",
            )}
          />
        ))}
      </div>
    </div>
  );
}
