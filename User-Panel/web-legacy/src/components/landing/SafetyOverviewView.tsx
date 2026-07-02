"use client";

import Image from "next/image";
import Link from "next/link";
import { motion } from "framer-motion";
import { ChevronRight, Users } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import {
  safetyOverviewPage,
  type SafetyAudience,
} from "@/constants/safety-content";
import { cn } from "@/lib/utils";

const fadeUp = {
  initial: { opacity: 0, y: 16 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true, margin: "-40px" },
  transition: { duration: 0.45, ease: "easeOut" as const },
};

function HeroImageCard({
  src,
  alt,
  className,
}: {
  src: string;
  alt: string;
  className: string;
}) {
  return (
    <div className={cn("absolute", className)}>
      <span className="absolute -bottom-2 -right-2 h-full w-full rounded-[20px] bg-secondary sm:-bottom-3 sm:-right-3" />
      <div className="relative h-full w-full overflow-hidden rounded-[20px] border border-border bg-card shadow-md">
        <Image
          src={src}
          alt={alt}
          fill
          className="object-cover"
          sizes="(max-width: 640px) 160px, 176px"
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

type SafetyOverviewViewProps = {
  onTabChange: (tab: Exclude<SafetyAudience, "all">) => void;
};

export function SafetyOverviewView({ onTabChange }: SafetyOverviewViewProps) {
  const { hero, coversEveryone, measures, wayForward } = safetyOverviewPage;

  return (
    <>
      {/* Hero */}
      <section className="px-6 py-14 md:py-20" aria-labelledby="overview-hero-heading">
        <div className="mx-auto grid max-w-6xl items-center gap-12 lg:grid-cols-2 lg:gap-20">
          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.35 }}
          >
            <h1
              id="overview-hero-heading"
              className="font-heading text-4xl font-bold leading-tight text-foreground sm:text-5xl lg:text-[3.25rem]"
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
            className="relative mx-auto h-48 w-full max-w-md sm:h-52 lg:max-w-none"
          >
            {hero.images.map((img) => (
              <HeroImageCard key={img.alt} {...img} />
            ))}
          </motion.div>
        </div>
      </section>

      {/* Covers Everyone */}
      <section
        id="covers-everyone"
        className="scroll-mt-20 border-t border-border px-6 py-16 md:py-24"
        aria-labelledby="covers-everyone-heading"
      >
        <div className="mx-auto max-w-6xl">
          <motion.h2
            {...fadeUp}
            id="covers-everyone-heading"
            className="font-heading text-3xl font-bold text-foreground sm:text-4xl"
          >
            {coversEveryone.title}
          </motion.h2>

          <div className="mt-10 grid gap-8 sm:grid-cols-2">
            {coversEveryone.cards.map((card, index) => (
              <motion.article
                key={card.id}
                {...fadeUp}
                transition={{ ...fadeUp.transition, delay: index * 0.08 }}
              >
                <div className="relative aspect-[2/1] overflow-hidden rounded-[20px] border border-border bg-card shadow-sm">
                  <Image
                    src={card.image}
                    alt={card.alt}
                    fill
                    className="object-cover"
                    sizes="(max-width: 640px) 100vw, 480px"
                  />
                </div>
                <h3 className="mt-5 font-heading text-xl font-bold text-foreground sm:text-2xl">
                  {card.title}
                </h3>
                <p className="mt-3 text-sm leading-relaxed text-muted-foreground sm:text-base">
                  {card.description}
                </p>
                <button
                  type="button"
                  onClick={() => onTabChange(card.tab)}
                  className="mt-4 inline-flex items-center gap-1 font-heading text-sm font-bold uppercase tracking-wide text-primary transition-colors hover:text-primary/80"
                >
                  Know More
                  <ChevronRight className="h-4 w-4" />
                </button>
              </motion.article>
            ))}
          </div>
        </div>
      </section>

      {/* Safety Measures 2×2 grid */}
      <section
        id="safety-measures"
        className="scroll-mt-20 bg-secondary px-6 py-16 md:py-24"
        aria-labelledby="overview-measures-heading"
      >
        <div className="mx-auto max-w-6xl">
          <div className="grid gap-0 sm:grid-cols-2">
            <motion.div
              {...fadeUp}
              className="flex flex-col justify-center border-b border-foreground/10 p-6 sm:border-b sm:border-r sm:p-8 lg:p-10"
            >
              <Users className="h-8 w-8 text-foreground" strokeWidth={1.5} />
              <h2
                id="overview-measures-heading"
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

      {/* Way forward */}
      <section className="px-6 py-16 md:py-24" aria-labelledby="overview-way-forward-heading">
        <motion.div {...fadeUp} className="mx-auto max-w-6xl">
          <h2
            id="overview-way-forward-heading"
            className="font-heading text-3xl font-bold text-foreground sm:text-4xl"
          >
            {wayForward.title}
          </h2>
          <p className="mt-5 max-w-3xl text-base leading-relaxed text-muted-foreground sm:text-lg">
            {wayForward.description}
          </p>
          <Link
            href={wayForward.href}
            className="mt-6 inline-flex items-center gap-1 font-heading text-sm font-bold uppercase tracking-wide text-primary transition-colors hover:text-primary/80"
          >
            {wayForward.linkLabel}
            <ChevronRight className="h-4 w-4" />
          </Link>
        </motion.div>
      </section>
    </>
  );
}
