"use client";

import { motion, useReducedMotion, type HTMLMotionProps } from "framer-motion";
import { fadeUpVariants, revealViewport, transitions } from "@/lib/motion";
import { cn } from "@/lib/utils";

type AnimateInProps = Omit<HTMLMotionProps<"div">, "children"> & {
  children?: React.ReactNode;
  delay?: number;
};

export function AnimateIn({
  children,
  className,
  delay = 0,
  ...props
}: AnimateInProps) {
  const reduceMotion = useReducedMotion();

  if (reduceMotion) {
    return <div className={cn(className)}>{children}</div>;
  }

  return (
    <motion.div
      initial="hidden"
      whileInView="visible"
      viewport={revealViewport}
      variants={fadeUpVariants}
      transition={{ ...transitions.reveal, delay }}
      className={cn(className)}
      {...props}
    >
      {children}
    </motion.div>
  );
}
