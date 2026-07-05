"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";
import { AnimatePresence, motion } from "framer-motion";
import { ArrowRight, Check, MapPin, Tag, Zap } from "lucide-react";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/constants/routes";
import { landingFeatures } from "@/constants/services";
import { cn } from "@/lib/utils";

const featureMeta = [
  { icon: Zap, accent: "bg-primary", bar: "bg-primary" },
  { icon: Tag, accent: "bg-secondary", bar: "bg-secondary" },
  { icon: MapPin, accent: "bg-[#7346f4]", bar: "bg-[#7346f4]" },
] as const;

const AUTO_MS = 6000;

export function WhyWaveGoSection() {
  const router = useRouter();
  const [active, setActive] = useState(0);
  const [paused, setPaused] = useState(false);

  useEffect(() => {
    if (paused) return;
    const timer = setInterval(() => {
      setActive((i) => (i + 1) % landingFeatures.length);
    }, AUTO_MS);
    return () => clearInterval(timer);
  }, [paused]);

  const feature = landingFeatures[active];
  const meta = featureMeta[active] ?? featureMeta[0];
  const Icon = meta.icon;

  return (
    <section
      id="why-wavego"
      className="scroll-mt-20 bg-background px-6 py-20 lg:py-24"
      onMouseEnter={() => setPaused(true)}
      onMouseLeave={() => setPaused(false)}
    >
      <div className="mx-auto max-w-6xl">
        <p className="text-base font-bold uppercase tracking-[0.24em] text-primary sm:text-lg">
          Why Fast Bull
        </p>
        <div className="mt-4 h-px w-full bg-border" />

        {/* Header — left aligned, editorial */}
        <div className="mt-10 mb-12 max-w-2xl lg:mb-16">
          <h2 className="font-heading text-3xl font-bold text-foreground sm:text-4xl lg:text-[2.75rem] lg:leading-tight">
            The Fast Bull difference
          </h2>
          <p className="mt-4 text-base leading-relaxed text-muted-foreground sm:text-lg">
            Premium experience inspired by global standards — with a distinctly Indian touch.
          </p>
        </div>

        <div className="grid gap-10 lg:grid-cols-[280px_1fr] lg:gap-14">
          {/* Tab list */}
          <div className="flex gap-3 overflow-x-auto pb-1 lg:flex-col lg:overflow-visible lg:pb-0">
            {landingFeatures.map((item, idx) => {
              const isActive = idx === active;
              const { icon: TabIcon, bar } = featureMeta[idx] ?? featureMeta[0];

              return (
                <button
                  key={item.title}
                  type="button"
                  onClick={() => setActive(idx)}
                  className={cn(
                    "group relative flex min-w-[220px] shrink-0 items-start gap-4 rounded-2xl border px-4 py-4 text-left transition-all duration-300 lg:min-w-0 lg:w-full",
                    isActive
                      ? "border-primary/20 bg-card shadow-md shadow-primary/5"
                      : "border-transparent bg-muted/40 hover:border-border hover:bg-muted/60",
                  )}
                >
                  <span
                    className={cn(
                      "absolute top-4 bottom-4 left-0 w-1 rounded-full transition-all duration-300",
                      isActive ? bar : "bg-transparent",
                    )}
                  />
                  <span
                    className={cn(
                      "flex h-10 w-10 shrink-0 items-center justify-center rounded-xl transition-colors",
                      isActive ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground group-hover:bg-primary/10 group-hover:text-primary",
                    )}
                  >
                    <TabIcon className="h-5 w-5" />
                  </span>
                  <span className="min-w-0 pt-0.5">
                    <span className="block text-[11px] font-bold uppercase tracking-wider text-muted-foreground">
                      0{idx + 1}
                    </span>
                    <span
                      className={cn(
                        "mt-0.5 block font-heading text-base font-bold leading-snug",
                        isActive ? "text-foreground" : "text-foreground/75",
                      )}
                    >
                      {item.title}
                    </span>
                  </span>
                </button>
              );
            })}
          </div>

          {/* Spotlight panel */}
          <div className="relative overflow-hidden rounded-3xl border border-border bg-card shadow-xl shadow-primary/5">
            <AnimatePresence mode="wait">
              <motion.div
                key={active}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.35 }}
              >
                <div className="relative aspect-[16/9] w-full overflow-hidden sm:aspect-[2/1]">
                  <Image
                    src={feature.image}
                    alt={feature.title}
                    fill
                    className="object-cover"
                    sizes="(max-width: 1024px) 100vw, 65vw"
                    priority={active === 0}
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-black/10 to-transparent" />
                  <div className="absolute bottom-0 left-0 right-0 p-6 sm:p-8">
                    <div className="flex items-center gap-3">
                      <span className={cn("flex h-10 w-10 items-center justify-center rounded-xl text-white", meta.accent)}>
                        <Icon className="h-5 w-5" />
                      </span>
                      <div>
                        <p className="text-xs font-bold uppercase tracking-wider text-white/70">
                          Feature 0{active + 1}
                        </p>
                        <h3 className="font-heading text-2xl font-bold text-white sm:text-3xl">
                          {feature.title}
                        </h3>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="grid gap-6 p-6 sm:p-8 lg:grid-cols-[1fr_auto] lg:items-end">
                  <div>
                    <p className="text-base font-medium text-foreground">{feature.desc}</p>
                    <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                      {feature.body}
                    </p>
                    <ul className="mt-5 space-y-2.5">
                      {feature.points.map((point) => (
                        <li key={point} className="flex items-start gap-2.5 text-sm text-foreground/85">
                          <Check className="mt-0.5 h-4 w-4 shrink-0 text-primary" strokeWidth={2.5} />
                          {point}
                        </li>
                      ))}
                    </ul>
                  </div>
                  <Button
                    className="h-11 shrink-0 rounded-xl px-6 font-semibold"
                    onClick={() => router.push(ROUTES.login)}
                  >
                    Get started
                    <ArrowRight className="ml-1.5 h-4 w-4" />
                  </Button>
                </div>
              </motion.div>
            </AnimatePresence>
          </div>
        </div>

        {/* Mobile dots */}
        <div className="mt-6 flex justify-center gap-2 lg:hidden">
          {landingFeatures.map((_, idx) => (
            <button
              key={idx}
              type="button"
              aria-label={`Feature ${idx + 1}`}
              onClick={() => setActive(idx)}
              className={cn(
                "h-2 rounded-full transition-all",
                idx === active ? "w-6 bg-primary" : "w-2 bg-primary/25",
              )}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
