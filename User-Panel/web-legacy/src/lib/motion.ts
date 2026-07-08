/** Shared Bull Wave Rides motion tokens — Coastal Luxe, smooth ease-out feel */

export const easeOut = [0.22, 1, 0.36, 1] as const;

export const transitions = {
  page: { duration: 0.42, ease: easeOut },
  reveal: { duration: 0.52, ease: easeOut },
  fast: { duration: 0.32, ease: easeOut },
  spring: { type: "spring" as const, stiffness: 260, damping: 24 },
};

export const pageVariants = {
  hidden: { opacity: 0, y: 16 },
  visible: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -10 },
};

export const fadeUpVariants = {
  hidden: { opacity: 0, y: 28 },
  visible: { opacity: 1, y: 0 },
};

export const fadeInVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
};

export const slideDownVariants = {
  hidden: { opacity: 0, y: -12 },
  visible: { opacity: 1, y: 0 },
};

export const scaleInVariants = {
  hidden: { opacity: 0, scale: 0.96 },
  visible: { opacity: 1, scale: 1 },
};

export const staggerContainerVariants = {
  hidden: {},
  visible: {
    transition: { staggerChildren: 0.08, delayChildren: 0.06 },
  },
};

export const staggerItemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: transitions.reveal,
  },
};

export const revealViewport = { once: true, margin: "-56px" as const };
