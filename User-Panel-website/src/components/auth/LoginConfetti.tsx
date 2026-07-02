"use client";

import { motion } from "framer-motion";
import { useMemo } from "react";
import { WAVEGO_CONFETTI_COLORS } from "@/constants/brand";

interface LoginConfettiProps {
  active: boolean;
}

export function LoginConfetti({ active }: LoginConfettiProps) {
  const pieces = useMemo(
    () =>
      Array.from({ length: 36 }, (_, i) => ({
        id: i,
        x: (Math.random() - 0.5) * 280,
        y: -(80 + Math.random() * 120),
        rotate: Math.random() * 720 - 360,
        color: WAVEGO_CONFETTI_COLORS[i % WAVEGO_CONFETTI_COLORS.length],
        size: 4 + Math.random() * 6,
        delay: Math.random() * 0.15,
      })),
    []
  );

  if (!active) return null;

  return (
    <div className="pointer-events-none absolute inset-0 z-30 overflow-hidden" aria-hidden>
      {pieces.map((piece) => (
        <motion.span
          key={piece.id}
          className="absolute left-1/2 top-1/2 rounded-sm"
          style={{
            width: piece.size,
            height: piece.size * 0.6,
            backgroundColor: piece.color,
          }}
          initial={{ x: 0, y: 0, opacity: 1, rotate: 0, scale: 0 }}
          animate={{
            x: piece.x,
            y: piece.y,
            opacity: [1, 1, 0],
            rotate: piece.rotate,
            scale: [0, 1, 0.8],
          }}
          transition={{
            duration: 1.2,
            delay: piece.delay,
            ease: [0.22, 1, 0.36, 1],
          }}
        />
      ))}
    </div>
  );
}
