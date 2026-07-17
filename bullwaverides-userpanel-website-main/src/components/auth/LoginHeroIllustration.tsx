"use client";

import { motion } from "framer-motion";

/** Bull Wave rides brand palette — matches globals.css tokens for inline SVG */
const BRAND = {
  primary: "#73398f",
  secondary: "#c45cf7",
  background: "#ffffff",
  foreground: "#73398f",
  muted: "#f5f0ff",
  error: "#D66B6B",
  white: "#FFFFFF",
} as const;

export function LoginHeroIllustration() {
  return (
    <motion.div
      animate={{ y: [0, -10, 0] }}
      transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
      className="relative h-full w-full"
      aria-hidden
    >
      <svg
        viewBox="0 0 560 320"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="h-full w-full object-contain drop-shadow-2xl"
        role="img"
        aria-label="Bull Wave rides transportation services"
      >
        <defs>
          <linearGradient id="loginSky" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor={BRAND.secondary} stopOpacity="0.45" />
            <stop offset="100%" stopColor={BRAND.primary} stopOpacity="0.08" />
          </linearGradient>
          <linearGradient id="loginRoad" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stopColor={BRAND.background} />
            <stop offset="100%" stopColor={BRAND.muted} />
          </linearGradient>
          <filter id="loginGlow" x="-20%" y="-20%" width="140%" height="140%">
            <feGaussianBlur stdDeviation="6" result="blur" />
            <feMerge>
              <feMergeNode in="blur" />
              <feMergeNode in="SourceGraphic" />
            </feMerge>
          </filter>
        </defs>

        <rect
          x="8"
          y="8"
          width="544"
          height="304"
          rx="20"
          fill="url(#loginSky)"
          stroke="rgba(255,255,255,0.35)"
          strokeWidth="1.5"
        />

        <g opacity="0.9">
          <rect x="40" y="118" width="36" height="88" rx="4" fill={BRAND.white} fillOpacity="0.55" />
          <rect x="82" y="98" width="28" height="108" rx="4" fill={BRAND.white} fillOpacity="0.4" />
          <rect x="116" y="132" width="44" height="74" rx="4" fill={BRAND.white} fillOpacity="0.5" />
          <rect x="400" y="108" width="32" height="98" rx="4" fill={BRAND.white} fillOpacity="0.45" />
          <rect x="438" y="88" width="40" height="118" rx="4" fill={BRAND.white} fillOpacity="0.35" />
          <rect x="484" y="124" width="36" height="82" rx="4" fill={BRAND.white} fillOpacity="0.5" />
          <rect x="340" y="142" width="52" height="64" rx="4" fill={BRAND.white} fillOpacity="0.42" />
        </g>

        <path
          d="M48 248 C120 220, 180 260, 260 236 S400 210, 512 244"
          stroke={BRAND.secondary}
          strokeWidth="2"
          strokeDasharray="8 10"
          opacity="0.7"
        />
        <path
          d="M72 268 C150 250, 220 278, 310 258 S430 240, 520 262"
          stroke={BRAND.white}
          strokeWidth="1.5"
          strokeDasharray="6 8"
          opacity="0.35"
        />

        <path d="M0 278 H560 V320 H0 Z" fill="url(#loginRoad)" />
        <path d="M0 292 H560" stroke={BRAND.primary} strokeOpacity="0.12" strokeWidth="2" />

        <g transform="translate(88 214)">
          <rect x="0" y="18" width="58" height="28" rx="8" fill={BRAND.primary} />
          <rect x="6" y="8" width="34" height="22" rx="6" fill={BRAND.secondary} />
          <circle cx="14" cy="48" r="9" fill={BRAND.foreground} fillOpacity="0.75" />
          <circle cx="44" cy="48" r="9" fill={BRAND.foreground} fillOpacity="0.75" />
          <circle cx="14" cy="48" r="4" fill={BRAND.background} />
          <circle cx="44" cy="48" r="4" fill={BRAND.background} />
          <rect x="40" y="12" width="10" height="14" rx="2" fill={BRAND.background} fillOpacity="0.8" />
        </g>

        <g transform="translate(210 206)">
          <rect x="0" y="22" width="78" height="30" rx="10" fill={BRAND.primary} />
          <rect x="10" y="10" width="48" height="24" rx="8" fill={BRAND.white} fillOpacity="0.92" />
          <rect x="58" y="16" width="14" height="18" rx="4" fill={BRAND.secondary} />
          <circle cx="18" cy="54" r="10" fill={BRAND.foreground} fillOpacity="0.8" />
          <circle cx="60" cy="54" r="10" fill={BRAND.foreground} fillOpacity="0.8" />
          <circle cx="18" cy="54" r="4.5" fill={BRAND.background} />
          <circle cx="60" cy="54" r="4.5" fill={BRAND.background} />
          <rect x="24" y="4" width="20" height="8" rx="3" fill={BRAND.secondary} />
        </g>

        <g transform="translate(330 198)" filter="url(#loginGlow)">
          <ellipse cx="34" cy="62" rx="28" ry="6" fill={BRAND.primary} fillOpacity="0.15" />
          <circle cx="48" cy="18" r="9" fill={BRAND.background} />
          <path
            d="M48 26 C42 34, 36 40, 28 44 C24 46, 20 48, 16 50"
            stroke={BRAND.primary}
            strokeWidth="3"
            strokeLinecap="round"
          />
          <rect x="22" y="38" width="34" height="10" rx="5" fill={BRAND.primary} />
          <circle cx="20" cy="52" r="9" fill={BRAND.foreground} fillOpacity="0.8" />
          <circle cx="44" cy="52" r="9" fill={BRAND.foreground} fillOpacity="0.8" />
          <circle cx="20" cy="52" r="4" fill={BRAND.background} />
          <circle cx="44" cy="52" r="4" fill={BRAND.background} />
          <path d="M30 38 L38 30" stroke={BRAND.secondary} strokeWidth="3" strokeLinecap="round" />
        </g>

        <g transform="translate(420 200)">
          <rect x="0" y="20" width="88" height="34" rx="10" fill={BRAND.white} fillOpacity="0.95" />
          <rect x="0" y="20" width="88" height="34" rx="10" stroke={BRAND.primary} strokeWidth="2" />
          <rect x="8" y="28" width="36" height="18" rx="4" fill={BRAND.secondary} fillOpacity="0.55" />
          <path
            d="M58 37 H66 V45 H74 V37 H82 V29 H74 V21 H66 V29 H58 Z"
            fill={BRAND.error}
          />
          <circle cx="20" cy="56" r="10" fill={BRAND.foreground} fillOpacity="0.8" />
          <circle cx="68" cy="56" r="10" fill={BRAND.foreground} fillOpacity="0.8" />
          <circle cx="20" cy="56" r="4.5" fill={BRAND.background} />
          <circle cx="68" cy="56" r="4.5" fill={BRAND.background} />
          <rect x="74" y="8" width="10" height="14" rx="2" fill={BRAND.error} opacity="0.9" />
        </g>

        <g fill={BRAND.primary} fillOpacity="0.55">
          <path d="M170 86 C170 78.82 175.82 73 183 73 C190.18 73 196 78.82 196 86 C196 94.5 183 108 183 108 C183 108 170 94.5 170 86 Z" />
          <circle cx="183" cy="86" r="4" fill={BRAND.white} />
        </g>
        <g fill={BRAND.secondary} fillOpacity="0.8">
          <path d="M300 72 C300 66.48 304.48 62 310 62 C315.52 62 320 66.48 320 72 C320 78.8 310 90 310 90 C310 90 300 78.8 300 72 Z" />
          <circle cx="310" cy="72" r="3.5" fill={BRAND.white} />
        </g>
      </svg>
    </motion.div>
  );
}
