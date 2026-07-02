"use client";

import { motion } from "framer-motion";
import { AuthServiceImage } from "@/components/auth/AuthServiceImage";
import { loginAuthServices } from "@/constants/services";
import { staggerContainerVariants, staggerItemVariants, transitions } from "@/lib/motion";
import { cn } from "@/lib/utils";

interface LoginServicesPanelProps {
  className?: string;
}

export function LoginServicesPanel({ className }: LoginServicesPanelProps) {
  return (
    <motion.div
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={transitions.reveal}
      className={cn("flex max-h-[calc(100dvh-2rem)] flex-col", className)}
    >
      <div className="mb-5 shrink-0 lg:mb-6">
        <h2 className="font-heading text-[1.75rem] font-bold leading-[1.12] text-primary sm:text-[1.9rem] lg:text-[2rem]">
          One App.
          <br />
          Many Services.
        </h2>
        <p className="mt-2 max-w-md text-sm text-muted-foreground sm:text-base">
          Ride, send, or request — we&apos;ve got you.
        </p>
      </div>

      <motion.ul
        variants={staggerContainerVariants}
        initial="hidden"
        animate="visible"
        className="flex flex-col gap-2.5"
      >
        {loginAuthServices.map((service) => (
          <motion.li
            key={service.title}
            variants={staggerItemVariants}
            className="flex items-center gap-3 rounded-2xl border border-white/80 bg-card px-3.5 py-2.5 shadow-[0_6px_24px_-10px_rgba(49,82,110,0.13)] sm:gap-3.5 sm:px-4 sm:py-3"
          >
            <AuthServiceImage
              src={service.image}
              alt={service.title}
              variant={service.variant}
            />
            <div className="min-w-0 flex-1">
              <p className="font-heading text-[15px] font-bold leading-tight text-primary sm:text-base">
                {service.title}
              </p>
              <p className="mt-0.5 text-xs leading-snug text-muted-foreground sm:text-[13px]">
                {service.description}
              </p>
            </div>
          </motion.li>
        ))}
      </motion.ul>
    </motion.div>
  );
}
