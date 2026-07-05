/**
 * Fast Bull brand palette — single source of truth.
 * Keep in sync with `.cursor/rules/wavego-design.mdc` and `globals.css`.
 */
export const WAVEGO_BRAND = {
  primary: "#31526E",
  secondary: "#D8B39F",
  background: "#FAF8F4",
  foreground: "#20242C",
  muted: "#E8E4DD",
  mutedForeground: "#6086A8",
  success: "#5FA87A",
  warning: "#E8A95A",
  error: "#D66B6B",
  card: "#FFFFFF",
  primaryForeground: "#FFFFFF",
} as const;

export const WAVEGO_CONFETTI_COLORS = [
  WAVEGO_BRAND.primary,
  WAVEGO_BRAND.mutedForeground,
  WAVEGO_BRAND.secondary,
  WAVEGO_BRAND.success,
  WAVEGO_BRAND.background,
  WAVEGO_BRAND.warning,
] as const;
