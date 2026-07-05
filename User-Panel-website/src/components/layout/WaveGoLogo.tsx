import Image from "next/image";
import { cn } from "@/lib/utils";

type WaveGoLogoSize = "sm" | "md" | "lg";

const sizeStyles: Record<WaveGoLogoSize, { width: number; height: number; className: string }> = {
  sm: { width: 296, height: 118, className: "h-24 w-auto min-w-[12rem]" },
  md: { width: 352, height: 140, className: "h-28 w-auto min-w-[14rem]" },
  lg: { width: 448, height: 176, className: "h-36 w-auto min-w-[17rem]" },
};

interface WaveGoLogoProps {
  size?: WaveGoLogoSize;
  /** Kept for compatibility — logo image has no background box. */
  variant?: "default" | "light";
  className?: string;
  priority?: boolean;
}

export function WaveGoLogo({
  size = "md",
  className,
  priority = false,
}: WaveGoLogoProps) {
  const { width, height, className: sizeClassName } = sizeStyles[size];

  return (
    <Image
      src="/images/fast-bull-logo.png"
      alt="Fast Bull"
      width={width}
      height={height}
      priority={priority}
      className={cn("object-contain", sizeClassName, className)}
    />
  );
}
