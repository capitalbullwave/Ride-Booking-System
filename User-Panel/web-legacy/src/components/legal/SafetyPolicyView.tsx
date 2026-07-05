"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  AlertTriangle,
  ArrowLeft,
  ChevronRight,
  Headphones,
  HeartPulse,
  MapPin,
  Phone,
  ShieldCheck,
  UserCheck,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { ROUTES } from "@/constants/routes";
import { cn } from "@/lib/utils";

const pillars = [
  {
    icon: UserCheck,
    title: "Verified captains",
    description: "ID checks, background screening & training",
  },
  {
    icon: MapPin,
    title: "Live tracking",
    description: "Share trip status with trusted contacts",
  },
  {
    icon: Headphones,
    title: "24/7 support",
    description: "Safety team available around the clock",
  },
] as const;

const policySections: {
  icon: LucideIcon;
  title: string;
  points: string[];
  accent?: "default" | "emergency";
}[] = [
  {
    icon: UserCheck,
    title: "Verified partners",
    points: [
      "Every captain and ambulance crew completes identity verification before going online.",
      "Background checks and service-specific training are required for emergency partners.",
      "Vehicle documents and medical certifications are reviewed regularly.",
    ],
  },
  {
    icon: ShieldCheck,
    title: "In-app safety tools",
    points: [
      "Share live location with family or friends during an active trip.",
      "Contact Fast Bull support directly from the tracking screen.",
      "Ambulance requests share location and medical details only with assigned crews and partner hospitals.",
    ],
  },
  {
    icon: HeartPulse,
    title: "Emergency ambulance",
    accent: "emergency",
    points: [
      "Ambulance booking is reserved for genuine medical emergencies.",
      "Misuse of emergency services may lead to immediate account suspension.",
      "In life-threatening situations, call 112 (India) in addition to using the app.",
    ],
  },
  {
    icon: AlertTriangle,
    title: "Reporting & support",
    points: [
      "Report unsafe behaviour, vehicle issues, or trip concerns via Help & Support.",
      "Every safety report is reviewed by our trust & safety team.",
      "Accounts that violate community guidelines may be suspended or removed.",
    ],
  },
  {
    icon: ShieldCheck,
    title: "Your responsibilities",
    points: [
      "Wear a helmet on two-wheeler rides where legally required.",
      "Verify vehicle number and captain details before boarding.",
      "Provide accurate pickup and medical information for faster response.",
    ],
  },
];

const quickActions = [
  {
    label: "Help & Support",
    description: "Report an issue or get assistance",
    href: ROUTES.profileHelp,
    icon: Headphones,
  },
  {
    label: "Ambulance SOS",
    description: "Request emergency medical transport",
    href: ROUTES.ambulance,
    icon: HeartPulse,
  },
  {
    label: "Call 112",
    description: "National emergency number (India)",
    href: "tel:112",
    icon: Phone,
    external: true,
  },
] as const;

function PolicyCard({
  icon: Icon,
  title,
  points,
  accent = "default",
}: (typeof policySections)[number]) {
  const isEmergency = accent === "emergency";

  return (
    <article
      className={cn(
        "rounded-[20px] border bg-card p-5 shadow-sm transition-all hover:shadow-md",
        isEmergency
          ? "border-error/25 bg-error/[0.03] hover:border-error/40"
          : "border-border hover:border-primary/20"
      )}
    >
      <div className="mb-4 flex items-center gap-3">
        <div
          className={cn(
            "flex h-11 w-11 shrink-0 items-center justify-center rounded-[14px]",
            isEmergency ? "bg-error/10 text-error" : "bg-primary/10 text-primary"
          )}
        >
          <Icon className="h-5 w-5" />
        </div>
        <h2 className="font-heading text-base font-bold text-foreground">{title}</h2>
      </div>
      <ul className="space-y-2.5">
        {points.map((point) => (
          <li key={point} className="flex gap-2.5 text-sm leading-relaxed text-muted-foreground">
            <span
              className={cn(
                "mt-2 h-1.5 w-1.5 shrink-0 rounded-full",
                isEmergency ? "bg-error" : "bg-primary"
              )}
            />
            {point}
          </li>
        ))}
      </ul>
    </article>
  );
}

export function SafetyPolicyView() {
  const router = useRouter();

  return (
    <div className="flex min-h-screen w-full flex-col bg-background pb-10">
      {/* Hero */}
      <section className="relative overflow-hidden rounded-b-[32px] bg-primary px-5 pb-10 pt-5 text-white sm:px-8 md:px-12 md:pb-12 lg:px-16">
        <div className="absolute -right-16 -top-16 h-48 w-48 rounded-full bg-white/10 blur-3xl" />
        <div className="absolute -bottom-10 -left-10 h-32 w-32 rounded-full bg-secondary/20 blur-2xl" />

        <button
          onClick={() => router.back()}
          className="relative z-10 mb-6 flex h-10 w-10 items-center justify-center rounded-full bg-white/10 transition-colors hover:bg-white/20"
          aria-label="Go back"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>

        <div className="relative z-10 max-w-3xl">
          <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-[18px] bg-white/15 backdrop-blur-sm">
            <ShieldCheck className="h-7 w-7" />
          </div>
          <h1 className="font-heading text-3xl font-bold leading-tight sm:text-4xl">
            Safety Policy
          </h1>
          <p className="mt-3 max-w-2xl text-sm leading-relaxed text-white/80 sm:text-base">
            How Fast Bull protects riders, captains, and patients across rides, deliveries, and
            emergency ambulance services.
          </p>
          <p className="mt-4 text-xs font-medium text-white/50">Last updated: June 2026</p>
        </div>
      </section>

      {/* Pillars */}
      <section className="relative z-10 -mt-6 px-5 sm:px-8 md:px-12 lg:px-16">
        <div className="grid gap-3 sm:grid-cols-3">
          {pillars.map((pillar) => {
            const Icon = pillar.icon;
            return (
              <div
                key={pillar.title}
                className="rounded-[18px] border border-border bg-card p-4 shadow-md"
              >
                <div className="mb-2 flex h-9 w-9 items-center justify-center rounded-[12px] bg-secondary/30 text-primary">
                  <Icon className="h-4 w-4" />
                </div>
                <p className="font-heading text-sm font-bold text-foreground">{pillar.title}</p>
                <p className="mt-1 text-xs leading-snug text-muted-foreground">
                  {pillar.description}
                </p>
              </div>
            );
          })}
        </div>
      </section>

      {/* Quick actions */}
      <section className="mt-8 px-5 sm:px-8 md:px-12 lg:px-16">
        <h2 className="mb-3 font-heading text-lg font-bold text-foreground">Need help now?</h2>
        <div className="grid gap-3 sm:grid-cols-3">
          {quickActions.map((action) => {
            const Icon = action.icon;
            const className =
              "group flex items-center gap-3 rounded-[18px] border border-border bg-card p-4 text-left shadow-sm transition-all hover:border-primary/30 hover:shadow-md";

            const content = (
              <>
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-[12px] bg-primary/10 text-primary transition-colors group-hover:bg-primary group-hover:text-white">
                  <Icon className="h-4 w-4" />
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-semibold text-foreground">{action.label}</p>
                  <p className="text-xs text-muted-foreground">{action.description}</p>
                </div>
                <ChevronRight className="h-4 w-4 shrink-0 text-muted-foreground/40 transition-transform group-hover:translate-x-0.5 group-hover:text-primary" />
              </>
            );

            return "external" in action && action.external ? (
              <a key={action.label} href={action.href} className={className}>
                {content}
              </a>
            ) : (
              <Link key={action.label} href={action.href} className={className}>
                {content}
              </Link>
            );
          })}
        </div>
      </section>

      {/* Emergency callout */}
      <section className="mt-8 px-5 sm:px-8 md:px-12 lg:px-16">
        <div className="flex gap-4 rounded-[20px] border border-error/25 bg-error/[0.04] p-5">
          <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-[14px] bg-error/10 text-error">
            <Phone className="h-5 w-5" />
          </div>
          <div>
            <p className="font-heading text-sm font-bold text-foreground">
              Life-threatening emergency?
            </p>
            <p className="mt-1 text-sm leading-relaxed text-muted-foreground">
              Call <strong className="text-foreground">112</strong> immediately. Fast Bull ambulance
              is a supplement to — not a replacement for — national emergency services.
            </p>
          </div>
        </div>
      </section>

      {/* Policy sections */}
      <section className="mt-8 px-5 sm:px-8 md:px-12 lg:px-16">
        <h2 className="mb-4 font-heading text-lg font-bold text-foreground">Policy details</h2>
        <div className="grid gap-4 lg:grid-cols-2">
          {policySections.map((section) => (
            <PolicyCard key={section.title} {...section} />
          ))}
        </div>
      </section>

      {/* Related links */}
      <section className="mt-10 px-5 sm:px-8 md:px-12 lg:px-16">
        <div className="rounded-[20px] border border-border bg-muted/30 p-5">
          <p className="mb-3 font-heading text-sm font-bold text-foreground">Related policies</p>
          <div className="flex flex-wrap gap-2">
            {[
              { label: "Terms of Service", href: ROUTES.terms },
              { label: "Privacy Policy", href: ROUTES.privacy },
            ].map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="rounded-full border border-border bg-card px-4 py-2 text-xs font-semibold text-primary transition-colors hover:border-primary/30 hover:bg-primary/5"
              >
                {link.label}
              </Link>
            ))}
          </div>
          <p className="mt-4 text-xs text-muted-foreground">
            This is a UI preview document. A complete safety policy will be published before public
            launch.
          </p>
        </div>
      </section>
    </div>
  );
}
