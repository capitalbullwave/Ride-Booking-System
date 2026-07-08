import { playwriteEnglandJoined } from "@/lib/fonts";
import { cn } from "@/lib/utils";

type WaveGoLogoSize = "sm" | "md" | "lg";
type WaveGoLogoVariant = "default" | "light";

const sizeStyles: Record<WaveGoLogoSize, string> = {
  sm: "h-9 min-w-[5.5rem] rounded-lg px-2.5 text-[1.2rem]",
  md: "h-11 min-w-[6.75rem] rounded-xl px-3 text-[1.45rem]",
  lg: "h-14 min-w-[8.5rem] rounded-2xl px-4 text-[1.85rem]",
};

const variantStyles: Record<WaveGoLogoVariant, string> = {
  default: "bg-primary text-white shadow-md shadow-primary/20",
  light: "bg-white text-primary shadow-lg shadow-black/10",
};

interface WaveGoLogoProps {
  size?: WaveGoLogoSize;
  variant?: WaveGoLogoVariant;
  className?: string;
}

export function WaveGoLogo({
  size = "md",
  variant = "default",
  className,
}: WaveGoLogoProps) {
  return (
    <div
      className={cn(
        "inline-flex items-center justify-center",
        sizeStyles[size],
        variantStyles[variant],
        className
      )}
    >
      <span
        className={cn(
          playwriteEnglandJoined.className,
          "leading-none [font-feature-settings:'calt'_1,'liga'_1,'kern'_1]"
        )}
      >
        Bull Wave Rides
      </span>
    </div>
  );
}
