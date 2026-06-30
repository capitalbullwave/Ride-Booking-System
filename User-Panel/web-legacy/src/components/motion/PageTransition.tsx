"use client";

import { motion, useReducedMotion } from "framer-motion";
import { pageVariants, transitions } from "@/lib/motion";

export function PageTransition({ children }: { children: React.ReactNode }) {
  const reduceMotion = useReducedMotion();

  if (reduceMotion) {
    return <>{children}</>;
  }

  return (
    <motion.div
      initial="hidden"
      animate="visible"
      exit="exit"
      variants={pageVariants}
      transition={transitions.page}
    >
      {children}
    </motion.div>
  );
}
