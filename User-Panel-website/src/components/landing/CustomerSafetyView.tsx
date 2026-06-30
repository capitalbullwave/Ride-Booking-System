"use client";

import Image from "next/image";
import Link from "next/link";
import { useState } from "react";
import { motion } from "framer-motion";
import { ChevronRight, Plus } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { customerSafetyPage } from "@/constants/safety-content";
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
        className="absolute left-4 top-4 h-[calc(100%-1rem)] w-[calc(100%-1rem)] rounded-[20px] bg-secondary sm:left-6 sm:top-6"
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

function VerificationAccordion({
  items,
}: {
  items: readonly { id: string; title: string; content: string }[];
}) {
  const [openId, setOpenId] = useState<string | null>(null);

  return (
    <div className="divide-y divide-border border-t border-border">
      {items.map((item) => {
        const isOpen = openId === item.id;
        return (
          <div key={item.id}>
            <button
              type="button"
              aria-expanded={isOpen}
              aria-controls={`verification-panel-${item.id}`}
              onClick={() => setOpenId(isOpen ? null : item.id)}
              className="flex w-full items-center justify-between gap-4 py-5 text-left transition-colors hover:text-primary"
            >
              <span className="font-heading text-base font-bold text-foreground sm:text-lg">
                {item.title}
              </span>
              <Plus
                className={cn(
                  "h-5 w-5 shrink-0 text-muted-foreground transition-transform duration-200",
                  isOpen && "rotate-45"
                )}
                strokeWidth={2}
              />
            </button>
            {isOpen && (
              <div
                id={`verification-panel-${item.id}`}
                className="pb-5 pr-8"
              >
                <p className="text-sm leading-relaxed text-muted-foreground sm:text-base">
                  {item.content}
                </p>
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}

function AppSafetyFeature({
  icon: Icon,
  title,
  description,
  bullets,
}: {
  icon: LucideIcon;
  title: string;
  description: string;
  bullets?: readonly string[];
}) {
  return (
    <motion.div {...fadeUp} className="flex flex-col">
      <Icon className="h-8 w-8 text-foreground" strokeWidth={1.5} />
      <h3 className="mt-4 font-heading text-lg font-bold text-foreground sm:text-xl">
        {title}
      </h3>
      <p className="mt-2 text-sm leading-relaxed text-foreground/80 sm:text-base">
        {description}
      </p>
      {bullets && bullets.length > 0 && (
        <ul className="mt-3 space-y-1.5 text-sm text-foreground/80 sm:text-base">
          {bullets.map((item) => (
            <li key={item} className="flex items-start gap-2">
              <span className="mt-2 h-1 w-1 shrink-0 rounded-full bg-foreground/60" />
              {item}
            </li>
          ))}
        </ul>
      )}
    </motion.div>
  );
}

export function CustomerSafetyView() {
  const { hero, captainVerification, appFeatures, wayForward } = customerSafetyPage;

  return (
    <>
      {/* Hero: Customers Safety */}
      <section className="px-6 py-14 md:py-20" aria-labelledby="customer-safety-heading">
        <div className="mx-auto grid max-w-6xl items-center gap-12 lg:grid-cols-2 lg:gap-20">
          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.35 }}
          >
            <h1
              id="customer-safety-heading"
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

      {/* Captain Verification */}
      <section
        id="captain-verification"
        className="scroll-mt-20 border-t border-border px-6 py-16 md:py-24"
        aria-labelledby="verification-heading"
      >
        <div className="mx-auto grid max-w-6xl items-start gap-12 lg:grid-cols-2 lg:gap-20">
          <motion.div {...fadeUp} className="order-2 lg:order-1">
            <div className="relative mx-auto w-full max-w-md lg:max-w-none">
              <div className="relative aspect-[4/3] overflow-hidden rounded-[20px] border border-border bg-card shadow-md">
                <Image
                  src={captainVerification.image}
                  alt={captainVerification.alt}
                  fill
                  className="object-cover"
                  sizes="(max-width: 1024px) 100vw, 480px"
                />
              </div>
            </div>
          </motion.div>

          <motion.div {...fadeUp} className="order-1 lg:order-2">
            <h2
              id="verification-heading"
              className="font-heading text-3xl font-bold text-foreground sm:text-4xl"
            >
              {captainVerification.title}
            </h2>
            <p className="mt-5 text-base leading-relaxed text-muted-foreground sm:text-lg">
              {captainVerification.description}
            </p>
            <div className="mt-8">
              <VerificationAccordion items={captainVerification.accordion} />
            </div>
          </motion.div>
        </div>
      </section>

      {/* App Safety Features */}
      <section
        id="app-safety-features"
        className="scroll-mt-20 bg-secondary px-6 py-16 md:py-24"
        aria-labelledby="app-features-heading"
      >
        <div className="mx-auto max-w-6xl">
          <motion.h2
            {...fadeUp}
            id="app-features-heading"
            className="font-heading text-3xl font-bold text-foreground sm:text-4xl"
          >
            {appFeatures.title}
          </motion.h2>

          <div className="mt-12 grid gap-10 sm:grid-cols-2 lg:gap-x-16 lg:gap-y-12">
            {appFeatures.features.map((feature) => (
              <AppSafetyFeature key={feature.title} {...feature} />
            ))}
          </div>
        </div>
      </section>

      {/* Way forward on Safety */}
      <section className="px-6 py-16 md:py-24" aria-labelledby="way-forward-heading">
        <motion.div {...fadeUp} className="mx-auto max-w-6xl">
          <h2
            id="way-forward-heading"
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
