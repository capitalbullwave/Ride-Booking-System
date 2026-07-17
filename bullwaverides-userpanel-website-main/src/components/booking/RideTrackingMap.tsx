"use client";

import { motion } from "framer-motion";
import { ServiceImage } from "@/components/home/ServiceImage";

interface RideTrackingMapProps {
  vehicleImage: string;
  vehicleName: string;
}

/** Captain → pickup route (viewBox 400 × 280) */
const ROUTE_PATH = "M 88 168 C 140 148, 200 198, 268 218 C 296 226, 312 228, 328 224";

export function RideTrackingMap({ vehicleImage, vehicleName }: RideTrackingMapProps) {
  return (
    <div className="relative h-64 w-full overflow-hidden bg-[#E8EDF2] sm:h-72">
      <svg
        viewBox="0 0 400 280"
        className="absolute inset-0 h-full w-full"
        preserveAspectRatio="xMidYMid slice"
        aria-hidden
      >
        <defs>
          <linearGradient id="trackMapBg" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#F0F4F8" />
            <stop offset="100%" stopColor="#E2E9F0" />
          </linearGradient>
        </defs>

        <rect width="400" height="280" fill="url(#trackMapBg)" />

        {/* City blocks */}
        <g fill="#D4DCE4" opacity="0.55">
          <rect x="24" y="32" width="56" height="40" rx="4" />
          <rect x="96" y="48" width="44" height="52" rx="4" />
          <rect x="168" y="24" width="64" height="36" rx="4" />
          <rect x="248" y="40" width="48" height="48" rx="4" />
          <rect x="320" y="28" width="56" height="44" rx="4" />
          <rect x="40" y="200" width="72" height="48" rx="4" />
          <rect x="200" y="236" width="80" height="36" rx="4" />
        </g>

        {/* Roads */}
        <g stroke="#FFFFFF" strokeWidth="10" strokeLinecap="round" opacity="0.9">
          <path d="M0 90 H400 M0 150 H400 M0 210 H400" />
          <path d="M80 0 V280 M200 0 V280 M320 0 V280" />
        </g>
        <g stroke="#C8D3DE" strokeWidth="1.5" opacity="0.6">
          <path d="M0 90 H400 M0 150 H400 M0 210 H400" />
          <path d="M80 0 V280 M200 0 V280 M320 0 V280" />
        </g>

        {/* Full trip path (pickup → drop), faint */}
        <path
          d="M 328 224 C 340 180, 348 120, 352 72"
          stroke="#73398f"
          strokeWidth="2"
          strokeDasharray="5 7"
          fill="none"
          opacity="0.25"
        />

        {/* Captain → pickup route */}
        <path
          d={ROUTE_PATH}
          stroke="#73398f"
          strokeWidth="5"
          fill="none"
          strokeLinecap="round"
          opacity="0.9"
        />

        {/* Drop — destination */}
        <circle cx="352" cy="72" r="11" fill="#D66B6B" stroke="#FFFFFF" strokeWidth="3" />
        <circle cx="352" cy="72" r="4" fill="#FFFFFF" />

        {/* Pickup — rider waiting */}
        <circle cx="328" cy="224" r="12" fill="#5FA87A" stroke="#FFFFFF" strokeWidth="3" />
        <circle cx="328" cy="224" r="4.5" fill="#FFFFFF" />
      </svg>

      {/* Animated captain on route */}
      <motion.div
        className="absolute z-10"
        style={{ left: "22%", top: "56%" }}
        animate={{ left: ["22%", "28%", "34%"], top: ["56%", "54%", "52%"] }}
        transition={{ duration: 4, repeat: Infinity, repeatType: "reverse", ease: "easeInOut" }}
      >
        <div className="relative">
          <div className="absolute -inset-2 animate-ping rounded-full bg-primary/20" />
          <div className="relative flex h-14 w-14 items-center justify-center overflow-hidden rounded-full border-[3px] border-card bg-card shadow-lg shadow-primary/25">
            <ServiceImage
              src={vehicleImage}
              alt={vehicleName}
              imageClassName="object-contain p-1.5"
            />
          </div>
        </div>
      </motion.div>

      {/* Pickup label */}
      <div
        className="absolute z-10 -translate-x-1/2 -translate-y-full"
        style={{ left: "82%", top: "80%" }}
      >
        <span className="rounded-md bg-card px-2 py-0.5 text-[10px] font-bold text-success shadow-sm">
          Pickup
        </span>
      </div>

      {/* Drop label */}
      <div
        className="absolute z-10 -translate-x-1/2 -translate-y-full"
        style={{ left: "88%", top: "26%" }}
      >
        <span className="rounded-md bg-card px-2 py-0.5 text-[10px] font-bold text-destructive shadow-sm">
          Drop
        </span>
      </div>
    </div>
  );
}
