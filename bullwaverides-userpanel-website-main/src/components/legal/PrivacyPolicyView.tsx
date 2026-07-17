"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  ArrowLeft,
  Bell,
  CreditCard,
  Database,
  Eye,
  Lock,
  MapPin,
  ShieldCheck,
  Smartphone,
  User,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { ROUTES } from "@/constants/routes";
import { cn } from "@/lib/utils";

const pillars = [
  {
    icon: Lock,
    title: "Encrypted",
    description: "Data protected in transit and at rest",
  },
  {
    icon: Eye,
    title: "Transparent",
    description: "Clear about what we collect and why",
  },
  {
    icon: ShieldCheck,
    title: "Never sold",
    description: "We do not sell your personal information",
  },
] as const;

const dataTypes = [
  { icon: User, label: "Name & phone", detail: "Account & verification" },
  { icon: MapPin, label: "Location", detail: "During active trips only" },
  { icon: CreditCard, label: "Payments", detail: "Wallet & fare processing" },
  { icon: Smartphone, label: "Device info", detail: "App performance & security" },
  { icon: Bell, label: "Preferences", detail: "Notifications & settings" },
  { icon: Database, label: "Trip history", detail: "Bookings & receipts" },
] as const;

const policySections: {
  icon: LucideIcon;
  title: string;
  points: string[];
}[] = [
  {
    icon: Database,
    title: "Information we collect",
    points: [
      "Account details such as your name, phone number, and email when you sign up.",
      "Real-time location during active rides, deliveries, and ambulance requests.",
      "Payment and wallet information needed to process fares and refunds.",
      "Emergency medical details you provide when booking an ambulance.",
      "Trip history, ratings, and support conversations to improve our services.",
    ],
  },
  {
    icon: Eye,
    title: "How we use your data",
    points: [
      "Match you with nearby captains and ambulance partners.",
      "Process payments, send receipts, and manage your Bull Wave rides Wallet.",
      "Enable live tracking, safety features, and in-app notifications.",
      "Investigate safety reports and respond to support requests.",
      "Improve app performance through anonymised usage analytics.",
    ],
  },
  {
    icon: ShieldCheck,
    title: "Sharing & security",
    points: [
      "Location and contact details are shared with assigned captains or medical crews during active bookings only.",
      "Hospital partners receive medical information for ambulance dispatches.",
      "Payment processors handle transactions — Bull Wave rides does not store full card numbers.",
      "We may disclose data to authorities when required by law or in safety emergencies.",
      "All data is encrypted in transit (TLS) and at rest on secure servers.",
    ],
  },
  {
    icon: User,
    title: "Your choices & rights",
    points: [
      "Update your name, phone, and email anytime in Profile → Account Settings.",
      "Manage notification preferences from the Notifications page.",
      "Request a copy of your data or ask for deletion via Help & Support.",
      "Some data may be retained for legal, tax, or safety reasons after account deletion.",
      "You can log out or delete your account by contacting our support team.",
    ],
  },
];

function PolicyCard({
  icon: Icon,
  title,
  points,
}: (typeof policySections)[number]) {
  return (
    <article className="rounded-[20px] border border-border bg-card p-5 shadow-sm transition-all hover:border-primary/20 hover:shadow-md">
      <div className="mb-4 flex items-center gap-3">
        <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-[14px] bg-primary/10 text-primary">
          <Icon className="h-5 w-5" />
        </div>
        <h2 className="font-heading text-base font-bold text-foreground">{title}</h2>
      </div>
      <ul className="space-y-2.5">
        {points.map((point) => (
          <li key={point} className="flex gap-2.5 text-sm leading-relaxed text-muted-foreground">
            <span className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-primary" />
            {point}
          </li>
        ))}
      </ul>
    </article>
  );
}

export function PrivacyPolicyView() {
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
            <Lock className="h-7 w-7" />
          </div>
          <h1 className="font-heading text-3xl font-bold leading-tight sm:text-4xl">
            Privacy Policy
          </h1>
          <p className="mt-3 max-w-2xl text-sm leading-relaxed text-white/80 sm:text-base">
            How Bull Wave rides collects, uses, stores, and protects your personal information across
            rides, deliveries, wallet, and emergency ambulance services.
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

      {/* Data we collect grid */}
      <section className="mt-8 px-5 sm:px-8 md:px-12 lg:px-16">
        <h2 className="mb-3 font-heading text-lg font-bold text-foreground">Data we collect</h2>
        <div className="grid gap-3 grid-cols-2 sm:grid-cols-3">
          {dataTypes.map((item) => {
            const Icon = item.icon;
            return (
              <div
                key={item.label}
                className="rounded-[16px] border border-border bg-card p-3.5 shadow-sm"
              >
                <div className="mb-2 flex h-8 w-8 items-center justify-center rounded-[10px] bg-muted text-primary">
                  <Icon className="h-4 w-4" />
                </div>
                <p className="text-xs font-semibold text-foreground">{item.label}</p>
                <p className="mt-0.5 text-[11px] text-muted-foreground">{item.detail}</p>
              </div>
            );
          })}
        </div>
      </section>

      {/* Trust callout */}
      <section className="mt-8 px-5 sm:px-8 md:px-12 lg:px-16">
        <div className="flex gap-4 rounded-[20px] border border-primary/20 bg-primary/[0.04] p-5">
          <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-[14px] bg-primary/10 text-primary">
            <ShieldCheck className="h-5 w-5" />
          </div>
          <div>
            <p className="font-heading text-sm font-bold text-foreground">
              Your privacy matters to us
            </p>
            <p className="mt-1 text-sm leading-relaxed text-muted-foreground">
              Bull Wave rides never sells your personal data to third parties. We collect only what is
              necessary to provide safe, reliable mobility services and keep your account secure.
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

      {/* Manage privacy */}
      <section className="mt-8 px-5 sm:px-8 md:px-12 lg:px-16">
        <h2 className="mb-3 font-heading text-lg font-bold text-foreground">Manage your privacy</h2>
        <div className="grid gap-3 sm:grid-cols-2">
          {[
            {
              label: "Account Settings",
              description: "Update phone, email & personal info",
              href: ROUTES.profileAccountSettings,
            },
            {
              label: "Help & Support",
              description: "Request data access or deletion",
              href: ROUTES.profileHelp,
            },
          ].map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className={cn(
                "group rounded-[18px] border border-border bg-card p-4 shadow-sm transition-all",
                "hover:border-primary/30 hover:shadow-md"
              )}
            >
              <p className="text-sm font-semibold text-foreground">{link.label}</p>
              <p className="mt-1 text-xs text-muted-foreground">{link.description}</p>
            </Link>
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
              { label: "Safety Policy", href: ROUTES.safety },
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
            This is a UI preview document. A complete privacy policy will be published before public
            launch.
          </p>
        </div>
      </section>
    </div>
  );
}
