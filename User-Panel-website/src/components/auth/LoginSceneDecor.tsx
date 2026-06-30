"use client";

import { WAVEGO_BRAND } from "@/constants/brand";

export function LoginSceneDecor() {
  return (
    <div className="pointer-events-none absolute inset-0 overflow-hidden" aria-hidden>
      <div className="absolute inset-0 bg-background" />
      <div
        className="absolute inset-0"
        style={{
          background: `radial-gradient(ellipse 65% 55% at 72% 38%, ${WAVEGO_BRAND.mutedForeground}14, transparent 55%), radial-gradient(ellipse 80% 60% at 25% 30%, ${WAVEGO_BRAND.secondary}33, transparent 60%)`,
        }}
      />
      <div className="wavego-dot-grid absolute inset-0 opacity-[0.12]" />
    </div>
  );
}
