"use client";

import { motion } from "framer-motion";
import { ServiceImage } from "@/components/home/ServiceImage";
import { cn } from "@/lib/utils";

interface AuthServiceImageProps {
  src: string;
  alt: string;
  variant?: "default" | "ambulance";
  className?: string;
}

export function AuthServiceImage({
  src,
  alt,
  variant = "default",
  className,
}: AuthServiceImageProps) {
  const isAmbulance = variant === "ambulance";

  return (
    <div className={cn("relative shrink-0", className)}>
      <div
        className={cn(
          "absolute bottom-0 left-1/2 h-2.5 w-[72%] -translate-x-1/2 rounded-full blur-md",
          isAmbulance ? "bg-destructive/20" : "bg-primary/15"
        )}
        aria-hidden
      />
      <motion.div
        animate={{ y: [0, -4, 0] }}
        transition={{ duration: 2.8, repeat: Infinity, ease: "easeInOut" }}
        className={cn(
          "relative flex h-14 w-14 items-center justify-center overflow-hidden rounded-2xl transition-transform sm:h-16 sm:w-16",
          isAmbulance ? "bg-destructive/10" : "bg-secondary/30"
        )}
      >
        <ServiceImage src={src} alt={alt} imageClassName="scale-[1.4] p-0" />
      </motion.div>
    </div>
  );
}
