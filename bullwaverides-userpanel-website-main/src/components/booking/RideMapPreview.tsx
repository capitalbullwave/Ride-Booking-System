import { cn } from "@/lib/utils";

interface RideMapPreviewProps {
  className?: string;
}

export function RideMapPreview({ className }: RideMapPreviewProps) {
  return (
    <div
      className={cn(
        "relative h-52 w-full overflow-hidden rounded-[var(--radius-card)] border border-border bg-muted/40 sm:h-56",
        className
      )}
      aria-hidden
    >
      <svg
        viewBox="0 0 400 180"
        className="h-full w-full"
        preserveAspectRatio="xMidYMid slice"
      >
        <defs>
          <linearGradient id="mapBg" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#E8E4DD" />
            <stop offset="100%" stopColor="#f5f0ff" />
          </linearGradient>
        </defs>
        <rect width="400" height="180" fill="url(#mapBg)" />
        <path
          d="M0 90 H400 M0 45 H400 M0 135 H400 M100 0 V180 M200 0 V180 M300 0 V180"
          stroke="#73398f"
          strokeOpacity="0.08"
          strokeWidth="1"
        />
        <path
          d="M60 120 C120 80, 180 100, 240 70 S340 50, 340 50"
          stroke="#73398f"
          strokeWidth="3"
          strokeDasharray="6 8"
          fill="none"
          opacity="0.35"
        />
        <path
          d="M70 115 C130 85, 190 95, 250 72 S330 58, 335 58"
          stroke="#73398f"
          strokeWidth="4"
          fill="none"
          strokeLinecap="round"
        />
        <circle cx="70" cy="115" r="8" fill="#5FA87A" stroke="#fff" strokeWidth="2" />
        <circle cx="335" cy="58" r="8" fill="#D66B6B" stroke="#fff" strokeWidth="2" />
      </svg>
      <div className="absolute bottom-2 left-2 rounded-md bg-card/90 px-2 py-1 text-[10px] font-medium text-muted-foreground shadow-sm backdrop-blur-sm">
        Route preview
      </div>
    </div>
  );
}
