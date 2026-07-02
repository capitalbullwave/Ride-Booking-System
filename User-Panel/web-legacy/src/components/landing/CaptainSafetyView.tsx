"use client";

import Image from "next/image";
import { motion } from "framer-motion";
import { Users } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { captainSafetyPage } from "@/constants/safety-content";
import { cn } from "@/lib/utils";

const fadeUp = {
  initial: { opacity: 0, y: 16 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true, margin: "-40px" },
  transition: { duration: 0.45, ease: "easeOut" as const },
};

function OffsetHeroImage({ src, alt }: { src: string; alt: string }) {
  return (
    <div className="relative mx-auto w-full max-w-sm lg:max-w-none">
      <span
        className="absolute bottom-0 right-0 h-[calc(100%-1rem)] w-[calc(100%-1rem)] translate-x-3 translate-y-3 rounded-[20px] bg-secondary sm:translate-x-4 sm:translate-y-4"
        aria-hidden
      />
      <div className="relative aspect-[4/3] overflow-hidden rounded-[20px] border border-border bg-card shadow-md">
        <Image
          src={src}
          alt={alt}
          fill
          className="object-cover"
          sizes="(max-width: 1024px) 100vw, 480px"
          priority
        />
      </div>
    </div>
  );
}

function MeasureCell({
  icon: Icon,
  title,
  description,
}: {
  icon: LucideIcon;
  title: string;
  description: string;
}) {
  return (
    <div className="flex flex-col p-6 sm:p-8 lg:p-10">
      <Icon className="h-8 w-8 text-foreground" strokeWidth={1.5} />
      <h3 className="mt-4 font-heading text-lg font-bold text-foreground sm:text-xl">
        {title}
      </h3>
      <p className="mt-2 text-sm leading-relaxed text-foreground/80 sm:text-base">
        {description}
      </p>
    </div>
  );
}

export function CaptainSafetyView() {
  const { hero, measures } = captainSafetyPage;

  return (
    <>
      {/* Hero */}
      <section className="px-6 py-14 md:py-20" aria-labelledby="captain-safety-heading">
        <div className="mx-auto grid max-w-6xl items-center gap-12 lg:grid-cols-2 lg:gap-20">
          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.35 }}
          >
            <h1
              id="captain-safety-heading"
              className="font-heading text-4xl font-bold leading-tight text-foreground sm:text-5xl"
            >
              {hero.title}
            </h1>
            <p className="mt-6 max-w-lg text-base leading-relaxed text-muted-foreground sm:text-lg">
              {hero.description}
            </p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.35, delay: 0.08 }}
          >
            <OffsetHeroImage src={hero.image} alt={hero.alt} />
          </motion.div>
        </div>
      </section>

      {/* Safety Measures 2×2 grid */}
      <section
        id="captain-safety-measures"
        className="scroll-mt-20 bg-secondary px-6 py-16 md:py-24"
        aria-labelledby="captain-measures-heading"
      >
        <div className="mx-auto max-w-6xl">
          <div className="grid gap-0 sm:grid-cols-2">
            <motion.div
              {...fadeUp}
              className="flex flex-col justify-center border-b border-foreground/10 p-6 sm:border-b sm:border-r sm:p-8 lg:p-10"
            >
              <Users className="h-8 w-8 text-foreground" strokeWidth={1.5} />
              <h2
                id="captain-measures-heading"
                className="mt-4 font-heading text-2xl font-bold leading-snug text-foreground sm:text-3xl lg:text-4xl"
              >
                {measures.heading}
              </h2>
            </motion.div>

            {measures.items.map((item, index) => (
              <motion.div
                key={item.title}
                {...fadeUp}
                transition={{ ...fadeUp.transition, delay: index * 0.06 }}
                className={cn(
                  "border-b border-foreground/10",
                  index === 0 && "sm:border-r",
                  index === 1 && "sm:border-b-0",
                  index === 2 && "sm:border-r sm:border-b-0"
                )}
              >
                <MeasureCell {...item} />
              </motion.div>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
