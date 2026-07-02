"use client";

import { motion, useReducedMotion, type HTMLMotionProps } from "framer-motion";
import {
  staggerContainerVariants,
  staggerItemVariants,
  revealViewport,
  transitions,
} from "@/lib/motion";
import { cn } from "@/lib/utils";

type StaggerProps = Omit<HTMLMotionProps<"div">, "children"> & {
  children?: React.ReactNode;
};

export function Stagger({ children, className, ...props }: StaggerProps) {
  const reduceMotion = useReducedMotion();

  if (reduceMotion) {
    return <div className={cn(className)}>{children}</div>;
  }

  return (
    <motion.div
      initial="hidden"
      whileInView="visible"
      viewport={revealViewport}
      variants={staggerContainerVariants}
      className={cn(className)}
      {...props}
    >
      {children}
    </motion.div>
  );
}

type StaggerItemProps = Omit<HTMLMotionProps<"div">, "children"> & {
  children?: React.ReactNode;
  index?: number;
};

export function StaggerItem({ children, className, index = 0, ...props }: StaggerItemProps) {
  const reduceMotion = useReducedMotion();

  if (reduceMotion) {
    return <div className={cn(className)}>{children}</div>;
  }

  return (
    <motion.div
      variants={staggerItemVariants}
      transition={{ ...transitions.reveal, delay: index * 0.04 }}
      className={cn(className)}
      {...props}
    >
      {children}
    </motion.div>
  );
}
