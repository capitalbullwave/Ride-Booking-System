"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";
import { AnimateIn } from "@/components/motion";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/constants/routes";
import { landingHeroSlides } from "@/constants/services";
import { Ambulance, PhoneCall, Share2, ShieldCheck } from "lucide-react";
import { getProtectedPath } from "@/lib/auth-session";

const highlights = [
  {
    icon: ShieldCheck,
    title: "Verified medical transport",
    description: "Matched with verified partners and clear trip details before you confirm.",
  },
  {
    icon: Share2,
    title: "Live trip sharing",
    description: "Share your route with family for peace of mind during urgent travel.",
  },
  {
    icon: PhoneCall,
    title: "24×7 emergency support",
    description: "Get help any time with in-app SOS and dedicated support workflows.",
  },
] as const;

export function SosSection() {
  const router = useRouter();

  return (
    <section id="sos" className="scroll-mt-20 bg-background px-6 py-20 lg:py-24">
      <AnimateIn>
        <div className="relative mx-auto max-w-6xl overflow-hidden rounded-[2rem] border border-border bg-card shadow-xl shadow-primary/5">
          <div className="pointer-events-none absolute -right-24 -top-24 h-80 w-80 rounded-full bg-destructive/10 blur-3xl" />
          <div className="pointer-events-none absolute -bottom-28 left-10 h-72 w-72 rounded-full bg-secondary/35 blur-3xl" />

          <div className="grid gap-10 p-8 sm:p-10 lg:grid-cols-[1.1fr_0.9fr] lg:items-center lg:gap-14 lg:p-12">
            <div>
              <p className="inline-flex w-fit items-center gap-2 rounded-full bg-destructive/10 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-destructive">
                <Ambulance className="h-4 w-4" />
                Emergency SOS
              </p>
              <h2 className="mt-4 font-heading text-3xl font-bold leading-tight text-foreground sm:text-4xl">
                Need help fast?
                <span className="block text-destructive">Request an ambulance in one tap.</span>
              </h2>
              <p className="mt-4 max-w-xl text-base leading-relaxed text-muted-foreground sm:text-lg">
                When every second counts, Fast Bull helps you request verified medical transport,
                track live ETA, and keep your family informed.
              </p>

              <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:items-center">
                <Button
                  size="lg"
                  className="h-12 rounded-xl bg-destructive px-8 font-bold text-white hover:bg-destructive/90"
                  onClick={() => router.push(getProtectedPath(ROUTES.ambulance))}
                >
                  Request Ambulance SOS
                </Button>
                <Button
                  size="lg"
                  variant="outline"
                  className="h-12 rounded-xl border-primary/20 bg-background px-8 font-bold text-primary hover:bg-primary/5"
                  onClick={() => router.push(ROUTES.safety)}
                >
                  Learn about safety
                </Button>
              </div>

              <div className="mt-10 grid gap-4 sm:grid-cols-3">
                {highlights.map(({ icon: Icon, title, description }) => (
                  <div key={title} className="rounded-2xl bg-muted/35 p-4">
                    <Icon className="h-5 w-5 text-primary" strokeWidth={2} />
                    <p className="mt-3 font-heading text-sm font-bold text-foreground">{title}</p>
                    <p className="mt-1 text-sm leading-relaxed text-muted-foreground">
                      {description}
                    </p>
                  </div>
                ))}
              </div>
            </div>

            <div className="relative mx-auto w-full max-w-sm lg:max-w-none">
              <div className="relative aspect-[5/4] overflow-hidden rounded-2xl shadow-2xl ring-2 ring-primary/10">
                <Image
                  src={landingHeroSlides[4].src}
                  alt="Fast Bull ambulance SOS"
                  fill
                  className="object-cover"
                  sizes="(max-width: 1024px) 100vw, 40vw"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-foreground/40 via-transparent to-transparent" />
              </div>
            </div>
          </div>
        </div>
      </AnimateIn>
    </section>
  );
}

