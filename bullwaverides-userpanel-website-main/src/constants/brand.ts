/**
 * Bull Wave rides brand palette — single source of truth.
 * Keep in sync with `globals.css`.
 */
export const WAVEGO_BRAND = {
  primary: "#73398f",
  secondary: "#c45cf7",
  foreground: "#73398f",
  background: "#ffffff",
  muted: "#f5f0ff",
  mutedForeground: "#a47eb6",
  success: "#5FA87A",
  warning: "#E8A95A",
  error: "#D66B6B",
  card: "#ffffff",
  primaryForeground: "#FFFFFF",
} as const;

export const WAVEGO_CONFETTI_COLORS = [
  WAVEGO_BRAND.secondary,
  WAVEGO_BRAND.primary,
  WAVEGO_BRAND.foreground,
  WAVEGO_BRAND.mutedForeground,
  WAVEGO_BRAND.success,
  WAVEGO_BRAND.warning,
] as const;
