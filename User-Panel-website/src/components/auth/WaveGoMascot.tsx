"use client";

import { motion, useReducedMotion } from "framer-motion";
import type { MascotControllerState } from "./mascot-types";
import { WAVEGO_BRAND } from "@/constants/brand";
import { transitions } from "@/lib/motion";

interface WaveGoMascotProps {
  state: MascotControllerState;
  className?: string;
  showCaption?: boolean;
}

/** Headlight centers — keep in sync with useMascotController eye coords */
const LEFT_LIGHT = { cx: 105, cy: 168 };
const RIGHT_LIGHT = { cx: 215, cy: 168 };

export function WaveGoMascot({ state, className, showCaption = true }: WaveGoMascotProps) {
  const reduceMotion = useReducedMotion();
  const {
    expression,
    isBlinking,
    isShaking,
    leftPupil,
    rightPupil,
    headTilt,
    showHands,
    celebrate,
  } = state;

  const grillePath = (() => {
    switch (expression) {
      case "happy":
        return "M 118 218 Q 160 242 202 218";
      case "confused":
        return "M 126 224 Q 160 210 194 224";
      case "sad":
        return "M 120 228 Q 160 206 200 228";
      case "shy":
        return "M 132 222 Q 160 214 188 222";
      default:
        return "M 122 220 Q 160 232 198 220";
    }
  })();

  const mirrorPose = (() => {
    if (showHands) {
      return { left: -72, right: 72, leftWheel: -4, rightWheel: 4 };
    }
    if (celebrate) {
      return { left: -28, right: 28, leftWheel: -10, rightWheel: 10 };
    }
    if (expression === "sad") {
      return { left: 18, right: -18, leftWheel: -3, rightWheel: 3 };
    }
    if (expression === "confused") {
      return { left: -42, right: 22, leftWheel: -6, rightWheel: 5 };
    }
    if (expression === "happy") {
      return { left: -22, right: 22, leftWheel: -8, rightWheel: 8 };
    }
    return { left: 12, right: -12, leftWheel: -4, rightWheel: 4 };
  })();

  const headlightGlow =
    celebrate || expression === "happy"
      ? WAVEGO_BRAND.background
      : WAVEGO_BRAND.background;

  return (
    <div className={className}>
      <motion.div
        animate={
          reduceMotion
            ? {}
            : {
                rotate: headTilt,
                y: celebrate ? [0, -12, 0] : 0,
                scale: celebrate ? [1, 1.05, 1] : 1,
              }
        }
        transition={
          celebrate
            ? { duration: 0.55, ease: [0.34, 1.56, 0.64, 1] }
            : { type: "spring", stiffness: 280, damping: 22 }
        }
        className="relative mx-auto w-full max-w-[340px]"
      >
        <motion.svg
          viewBox="0 0 320 380"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="h-auto w-full drop-shadow-lg"
          animate={
            reduceMotion
              ? {}
              : isShaking
                ? { rotate: [0, -4, 4, -3, 3, 0], x: [0, -3, 3, -2, 2, 0] }
                : { rotate: 0, x: 0 }
          }
          transition={{ duration: 0.65, ease: "easeInOut" }}
          aria-hidden
        >
          <defs>
            <linearGradient id="wg-car-body" x1="40" y1="60" x2="280" y2="340" gradientUnits="userSpaceOnUse">
              <stop stopColor={WAVEGO_BRAND.mutedForeground} />
              <stop offset="0.5" stopColor={WAVEGO_BRAND.primary} />
              <stop offset="1" stopColor={WAVEGO_BRAND.foreground} />
            </linearGradient>
            <linearGradient id="wg-car-roof" x1="80" y1="70" x2="240" y2="200" gradientUnits="userSpaceOnUse">
              <stop stopColor={WAVEGO_BRAND.mutedForeground} stopOpacity="0.35" />
              <stop offset="1" stopColor={WAVEGO_BRAND.primary} stopOpacity="0.05" />
            </linearGradient>
            <linearGradient id="wg-windshield" x1="100" y1="90" x2="220" y2="170" gradientUnits="userSpaceOnUse">
              <stop stopColor={WAVEGO_BRAND.background} stopOpacity="0.55" />
              <stop offset="1" stopColor={WAVEGO_BRAND.mutedForeground} stopOpacity="0.25" />
            </linearGradient>
            <filter id="wg-car-glow" x="-30%" y="-30%" width="160%" height="160%">
              <feGaussianBlur stdDeviation="8" result="blur" />
              <feMerge>
                <feMergeNode in="blur" />
                <feMergeNode in="SourceGraphic" />
              </feMerge>
            </filter>
            <radialGradient id="wg-headlight" cx="50%" cy="50%" r="50%">
              <stop offset="0%" stopColor={WAVEGO_BRAND.background} />
              <stop offset="70%" stopColor={WAVEGO_BRAND.background} stopOpacity="0.9" />
              <stop offset="100%" stopColor={WAVEGO_BRAND.mutedForeground} stopOpacity="0.3" />
            </radialGradient>
          </defs>

          {/* Ground shadow */}
          <ellipse cx="160" cy="348" rx="108" ry="14" fill={WAVEGO_BRAND.foreground} opacity="0.18" />

          {/* Ambient glow */}
          <ellipse cx="160" cy="210" rx="120" ry="100" fill={WAVEGO_BRAND.mutedForeground} opacity="0.1" filter="url(#wg-car-glow)" />

          {/* Mirror dandi — left */}
          <motion.g
            animate={{ rotate: mirrorPose.left }}
            style={{ transformOrigin: "48px 198px" }}
            transition={{ type: "spring", stiffness: 280, damping: 22 }}
          >
            <line x1="48" y1="198" x2="48" y2="248" stroke={WAVEGO_BRAND.foreground} strokeWidth="7" strokeLinecap="round" />
            <rect x="30" y="178" width="36" height="22" rx="8" fill={WAVEGO_BRAND.primary} stroke={WAVEGO_BRAND.mutedForeground} strokeWidth="2" />
          </motion.g>

          {/* Mirror dandi — right */}
          <motion.g
            animate={{ rotate: mirrorPose.right }}
            style={{ transformOrigin: "272px 198px" }}
            transition={{ type: "spring", stiffness: 280, damping: 22 }}
          >
            <line x1="272" y1="198" x2="272" y2="248" stroke={WAVEGO_BRAND.foreground} strokeWidth="7" strokeLinecap="round" />
            <rect x="254" y="178" width="36" height="22" rx="8" fill={WAVEGO_BRAND.primary} stroke={WAVEGO_BRAND.mutedForeground} strokeWidth="2" />
          </motion.g>

          {/* Wheels — leg dandi */}
          <motion.g
            animate={{ rotate: mirrorPose.leftWheel }}
            style={{ transformOrigin: "98px 318px" }}
            transition={{ type: "spring", stiffness: 260, damping: 20 }}
          >
            <circle cx="98" cy="318" r="28" fill={WAVEGO_BRAND.foreground} />
            <circle cx="98" cy="318" r="18" fill={WAVEGO_BRAND.primary} />
            <circle cx="98" cy="318" r="8" fill={WAVEGO_BRAND.mutedForeground} />
          </motion.g>
          <motion.g
            animate={{ rotate: mirrorPose.rightWheel }}
            style={{ transformOrigin: "222px 318px" }}
            transition={{ type: "spring", stiffness: 260, damping: 20 }}
          >
            <circle cx="222" cy="318" r="28" fill={WAVEGO_BRAND.foreground} />
            <circle cx="222" cy="318" r="18" fill={WAVEGO_BRAND.primary} />
            <circle cx="222" cy="318" r="8" fill={WAVEGO_BRAND.mutedForeground} />
          </motion.g>

          {/* Car body */}
          <path
            d="M 56 268 L 48 298 Q 46 312 60 318 L 260 318 Q 274 312 272 298 L 264 268 Q 262 248 248 240 L 220 228 L 100 228 L 72 240 Q 58 248 56 268 Z"
            fill="url(#wg-car-body)"
          />

          {/* Bumper */}
          <path
            d="M 64 278 Q 160 292 256 278"
            stroke={WAVEGO_BRAND.mutedForeground}
            strokeWidth="4"
            strokeLinecap="round"
            opacity="0.6"
          />

          {/* Cabin / roof */}
          <path
            d="M 88 228 L 108 148 Q 112 118 160 112 Q 208 118 212 148 L 232 228 Z"
            fill="url(#wg-car-roof)"
            stroke={WAVEGO_BRAND.foreground}
            strokeWidth="2"
            strokeLinejoin="round"
          />

          {/* Windshield */}
          <path
            d="M 102 222 L 118 152 Q 122 128 160 124 Q 198 128 202 152 L 218 222 Z"
            fill="url(#wg-windshield)"
            stroke={WAVEGO_BRAND.background}
            strokeWidth="1.5"
            strokeOpacity="0.35"
          />

          {/* Windshield glare */}
          <path
            d="M 118 158 L 132 210 L 148 210 L 128 152 Z"
            fill={WAVEGO_BRAND.background}
            opacity="0.12"
          />

          {/* Hood line */}
          <path d="M 88 228 L 232 228" stroke={WAVEGO_BRAND.foreground} strokeWidth="2" strokeOpacity="0.5" />

          {/* Fast Bull W on hood */}
          <path
            d="M 138 248 L 146 268 L 160 242 L 174 268 L 182 248"
            stroke={WAVEGO_BRAND.mutedForeground}
            strokeWidth="3.5"
            strokeLinecap="round"
            strokeLinejoin="round"
            opacity="0.75"
          />

          {/* Left headlight (eye) */}
          <g>
            <ellipse
              cx={LEFT_LIGHT.cx}
              cy={LEFT_LIGHT.cy}
              rx="30"
              ry="28"
              fill="url(#wg-headlight)"
              stroke={WAVEGO_BRAND.mutedForeground}
              strokeWidth="2"
              opacity={celebrate ? 1 : 0.95}
            />
            <motion.circle
              cx={LEFT_LIGHT.cx + leftPupil.x}
              cy={LEFT_LIGHT.cy + leftPupil.y}
              r="10"
              fill={WAVEGO_BRAND.foreground}
              transition={{ type: "spring", stiffness: 420, damping: 28 }}
            />
            <circle
              cx={LEFT_LIGHT.cx + leftPupil.x * 0.3 - 3}
              cy={LEFT_LIGHT.cy + leftPupil.y * 0.3 - 3}
              r="3"
              fill={WAVEGO_BRAND.background}
              opacity="0.9"
            />
            <motion.ellipse
              cx={LEFT_LIGHT.cx}
              cy={LEFT_LIGHT.cy}
              rx="30"
              ry={isBlinking || showHands ? 2 : 0}
              fill={WAVEGO_BRAND.primary}
              transition={{ duration: 0.1 }}
            />
            {celebrate && (
              <circle cx={LEFT_LIGHT.cx} cy={LEFT_LIGHT.cy} r="34" fill={headlightGlow} opacity="0.25" />
            )}
          </g>

          {/* Right headlight (eye) */}
          <g>
            <ellipse
              cx={RIGHT_LIGHT.cx}
              cy={RIGHT_LIGHT.cy}
              rx="30"
              ry="28"
              fill="url(#wg-headlight)"
              stroke={WAVEGO_BRAND.mutedForeground}
              strokeWidth="2"
              opacity={celebrate ? 1 : 0.95}
            />
            <motion.circle
              cx={RIGHT_LIGHT.cx + rightPupil.x}
              cy={RIGHT_LIGHT.cy + rightPupil.y}
              r="10"
              fill={WAVEGO_BRAND.foreground}
              transition={{ type: "spring", stiffness: 420, damping: 28 }}
            />
            <circle
              cx={RIGHT_LIGHT.cx + rightPupil.x * 0.3 - 3}
              cy={RIGHT_LIGHT.cy + rightPupil.y * 0.3 - 3}
              r="3"
              fill={WAVEGO_BRAND.background}
              opacity="0.9"
            />
            <motion.ellipse
              cx={RIGHT_LIGHT.cx}
              cy={RIGHT_LIGHT.cy}
              rx="30"
              ry={isBlinking || showHands ? 2 : 0}
              fill={WAVEGO_BRAND.primary}
              transition={{ duration: 0.1 }}
            />
            {celebrate && (
              <circle cx={RIGHT_LIGHT.cx} cy={RIGHT_LIGHT.cy} r="34" fill={headlightGlow} opacity="0.25" />
            )}
          </g>

          {/* Mirror covers headlights when password focused */}
          {showHands && (
            <>
              <motion.rect
                initial={false}
                animate={{ opacity: 1, y: 0 }}
                x="72"
                y="148"
                width="66"
                height="44"
                rx="12"
                fill={WAVEGO_BRAND.foreground}
                stroke={WAVEGO_BRAND.mutedForeground}
                strokeWidth="2"
                transition={transitions.fast}
              />
              <motion.rect
                initial={false}
                animate={{ opacity: 1, y: 0 }}
                x="182"
                y="148"
                width="66"
                height="44"
                rx="12"
                fill={WAVEGO_BRAND.foreground}
                stroke={WAVEGO_BRAND.mutedForeground}
                strokeWidth="2"
                transition={transitions.fast}
              />
            </>
          )}

          {/* Grille / mouth */}
          <motion.path
            d={grillePath}
            stroke={WAVEGO_BRAND.background}
            strokeWidth="4"
            strokeLinecap="round"
            fill="none"
            animate={{ d: grillePath }}
            transition={transitions.fast}
          />

          {/* Grille slats */}
          <g opacity="0.45">
            <line x1="148" y1="208" x2="148" y2="232" stroke={WAVEGO_BRAND.background} strokeWidth="3" strokeLinecap="round" />
            <line x1="160" y1="206" x2="160" y2="234" stroke={WAVEGO_BRAND.background} strokeWidth="3" strokeLinecap="round" />
            <line x1="172" y1="208" x2="172" y2="232" stroke={WAVEGO_BRAND.background} strokeWidth="3" strokeLinecap="round" />
          </g>

          {/* Confused indicator — hazard blink */}
          <motion.g
            animate={{ opacity: expression === "confused" ? [0.4, 1, 0.4] : 0 }}
            transition={{ duration: 0.8, repeat: expression === "confused" ? Infinity : 0 }}
          >
            <rect x="148" y="96" width="24" height="10" rx="3" fill={WAVEGO_BRAND.warning} />
          </motion.g>

          {/* Sad — dim beam */}
          <motion.g animate={{ opacity: expression === "sad" ? 0.5 : 0 }} transition={transitions.fast}>
            <path d="M 78 168 L 92 168 M 228 168 L 242 168" stroke={WAVEGO_BRAND.mutedForeground} strokeWidth="3" strokeLinecap="round" />
          </motion.g>

          {/* Celebration sparkles */}
          {celebrate && !reduceMotion && (
            <>
              {[0, 1, 2, 3].map((i) => (
                <motion.path
                  key={i}
                  d="M 0 -8 L 0 8 M -8 0 L 8 0"
                  stroke={WAVEGO_BRAND.background}
                  strokeWidth="3"
                  strokeLinecap="round"
                  initial={{ opacity: 0, scale: 0, x: 160, y: 80 }}
                  animate={{
                    opacity: [0, 1, 0],
                    scale: [0.4, 1.2, 0.6],
                    x: 160 + (i % 2 === 0 ? -1 : 1) * (50 + i * 20),
                    y: 60 + i * 14,
                    rotate: i * 45,
                  }}
                  transition={{ duration: 0.8, delay: i * 0.08, ease: transitions.fast.ease }}
                />
              ))}
            </>
          )}
        </motion.svg>

        {showCaption && (
          <>
            <motion.p
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ ...transitions.reveal, delay: 0.2 }}
              className="mt-4 text-center font-heading text-lg font-bold tracking-tight text-background sm:text-xl"
            >
              Your ride companion
            </motion.p>
            <p className="mt-1 text-center text-sm text-muted-foreground">
              Safe journeys, one wave at a time
            </p>
          </>
        )}
      </motion.div>
    </div>
  );
}
