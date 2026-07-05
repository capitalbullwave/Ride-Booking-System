"use client";

import { useRouter } from "next/navigation";
import {
  ArrowLeft,
  Car,
  ChevronRight,
  List,
  Mail,
  Search,
  ShieldCheck,
  Smartphone,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { WaveGoLogo } from "@/components/layout/WaveGoLogo";
import { supportTrips, helpTopics, type HelpTopic } from "@/data/mock/support";
import { ROUTES } from "@/constants/routes";

function topicIcon(topic: HelpTopic, index: number): typeof Car {
  if (topic.id === "trip") return Car;
  if (topic.id === "safety") return ShieldCheck;
  return index === 0 ? Car : List;
}

function MapPreview({ variant = "simple" }: { variant?: "simple" | "route" }) {
  if (variant === "route") {
    return (
      <div className="relative h-28 w-full overflow-hidden bg-muted">
        <div
          className="absolute inset-0 opacity-30"
          style={{
            backgroundImage:
              "linear-gradient(var(--border) 1px, transparent 1px), linear-gradient(90deg, var(--border) 1px, transparent 1px)",
            backgroundSize: "20px 20px",
          }}
        />
        <svg
          className="absolute inset-0 h-full w-full"
          viewBox="0 0 200 112"
          preserveAspectRatio="none"
        >
          <path
            d="M30 80 Q80 40 120 60 T170 30"
            fill="none"
            stroke="var(--primary)"
            strokeWidth="3"
          />
          <circle cx="30" cy="80" r="5" fill="var(--primary)" />
          <rect x="165" y="25" width="10" height="10" fill="var(--primary)" />
        </svg>
        <span className="absolute left-3 top-3 rounded-md bg-card/95 px-1.5 py-0.5 text-[9px] font-medium text-foreground shadow-sm">
          McDonald&apos;s
        </span>
      </div>
    );
  }

  return (
    <div className="relative h-28 w-full overflow-hidden bg-muted">
      <div className="absolute left-1/2 top-0 h-full w-8 -translate-x-1/2 bg-card/80" />
      <div className="absolute left-1/2 top-1/2 h-3 w-3 -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary" />
    </div>
  );
}

function SupportTripCard({
  service,
  address,
  date,
  status,
  price,
  mapVariant,
}: (typeof supportTrips)[number] & { mapVariant: "simple" | "route" }) {
  return (
    <button className="w-[220px] shrink-0 overflow-hidden rounded-[20px] border border-border bg-card text-left shadow-sm transition-all hover:border-primary/30 hover:shadow-md">
      <MapPreview variant={mapVariant} />
      <div className="space-y-1 p-3">
        <p className="text-xs text-muted-foreground">{service}</p>
        <p className="line-clamp-1 text-sm font-semibold text-foreground">{address}</p>
        <p className="text-xs text-muted-foreground">
          {date} | {status}
        </p>
        <p className="pt-1 text-lg font-bold text-primary">{price}</p>
      </div>
    </button>
  );
}

function TopicRow({
  icon: Icon,
  label,
  onClick,
  dark = false,
}: {
  icon: LucideIcon;
  label: string;
  onClick?: () => void;
  dark?: boolean;
}) {
  return (
    <button
      onClick={onClick}
      className={`group flex w-full items-center gap-4 border-b py-4 text-left transition-colors last:border-b-0 ${
        dark
          ? "border-white/10 hover:bg-white/5"
          : "border-border hover:bg-muted/40"
      }`}
    >
      <div
        className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-[12px] transition-colors ${
          dark
            ? "bg-white/10 text-white group-hover:bg-white/15"
            : "bg-secondary/30 text-primary group-hover:bg-primary/10"
        }`}
      >
        <Icon className="h-4 w-4" />
      </div>
      <span
        className={`flex-1 text-sm font-semibold ${dark ? "text-white" : "text-foreground"}`}
      >
        {label}
      </span>
      <ChevronRight
        className={`h-4 w-4 shrink-0 transition-transform group-hover:translate-x-0.5 ${
          dark
            ? "text-white/40 group-hover:text-white/70"
            : "text-muted-foreground/50 group-hover:text-primary"
        }`}
      />
    </button>
  );
}

interface HelpViewProps {
  onBack?: () => void;
}

export function HelpView({ onBack }: HelpViewProps) {
  const router = useRouter();

  const handleBack = () => {
    if (onBack) onBack();
    else router.back();
  };

  return (
    <div className="flex min-h-screen w-full flex-col bg-primary text-white">
      {/* Top bar — full width */}
      <header className="flex w-full items-center gap-4 px-5 py-4 sm:px-8 md:px-12 lg:px-16">
        <button
          onClick={handleBack}
          className="flex h-10 w-10 items-center justify-center rounded-full transition-colors hover:bg-white/10"
          aria-label="Go back"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
        <WaveGoLogo size="sm" variant="light" />
      </header>

      {/* Hero — full width, edge-to-edge */}
      <section className="w-full px-5 pb-10 sm:px-8 md:px-12 md:pb-14 lg:px-16 lg:pb-16">
        <div className="flex w-full flex-col gap-10 lg:flex-row lg:items-center lg:justify-between lg:gap-16">
          <div className="flex-1">
            <h1 className="font-heading text-3xl font-bold leading-tight sm:text-4xl md:text-5xl">
              Support Resources
              <br />
              for Fast Bull Riders
            </h1>

            <div className="mt-8 flex overflow-hidden rounded-[16px] bg-white/10 shadow-sm backdrop-blur-sm">
              <div className="flex flex-1 items-center gap-3 px-4 py-1">
                <Search className="h-4 w-4 shrink-0 text-white/60" />
                <Input
                  type="search"
                  placeholder="Search questions, keywords, topics"
                  className="h-12 flex-1 border-0 bg-transparent px-0 text-sm text-white shadow-none placeholder:text-white/50 focus-visible:ring-0"
                />
              </div>
              <Button
                variant="secondary"
                className="h-12 shrink-0 rounded-none rounded-r-[15px] bg-white px-6 font-semibold text-primary hover:bg-white/90"
              >
                Search
              </Button>
            </div>
          </div>

          <div className="relative mx-auto hidden h-64 w-44 shrink-0 overflow-hidden rounded-[24px] bg-white/10 lg:block xl:h-72 xl:w-52">
            <div className="absolute bottom-0 left-1/2 h-36 w-36 -translate-x-1/2 rounded-t-full bg-secondary/50" />
            <div className="absolute bottom-8 left-1/2 flex -translate-x-1/2 flex-col items-center">
              <div className="mb-2 h-16 w-12 rounded-full bg-secondary/70" />
              <div className="h-24 w-20 rounded-t-3xl bg-secondary" />
              <div className="mt-4 flex h-14 w-10 items-center justify-center rounded-[14px] bg-white shadow-md">
                <Smartphone className="h-6 w-6 text-primary" />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* All topics — full width on dark bg (Uber-style) */}
      <section className="w-full flex-1 px-5 pb-10 sm:px-8 md:px-12 lg:px-16">
        <h2 className="mb-2 font-heading text-xl font-bold sm:text-2xl">All topics</h2>
        <div className="w-full">
          {helpTopics.map((topic, index) => (
            <TopicRow
              key={topic.id}
              icon={topicIcon(topic, index)}
              label={topic.label}
              dark
              onClick={() => router.push(topic.route)}
            />
          ))}
        </div>
      </section>

      {/* Choose a trip — full-width light band */}
      <section className="w-full bg-background px-5 py-10 text-foreground sm:px-8 md:px-12 lg:px-16">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="font-heading text-lg font-bold sm:text-xl">Choose a trip</h2>
          <button className="rounded-full border border-border bg-card px-4 py-1.5 text-xs font-semibold text-primary transition-colors hover:border-primary/30 hover:bg-primary/5">
            View all
          </button>
        </div>

        <div className="-mx-5 flex gap-4 overflow-x-auto px-5 pb-2 scrollbar-hide sm:-mx-8 sm:px-8 md:-mx-12 md:px-12 lg:-mx-16 lg:px-16">
          {supportTrips.map((trip, index) => (
            <SupportTripCard
              key={trip.id}
              {...trip}
              mapVariant={index === 1 ? "route" : "simple"}
            />
          ))}
        </div>
      </section>

      {/* Support messages — full-width light band */}
      <section className="w-full border-t border-border bg-background px-5 py-8 text-foreground sm:px-8 md:px-12 lg:px-16">
        <h2 className="mb-2 font-heading text-lg font-bold sm:text-xl">Support messages</h2>
        <div className="w-full rounded-[20px] border border-border bg-card px-5 shadow-sm">
          <TopicRow
            icon={Mail}
            label="View all messages"
            onClick={() => router.push(ROUTES.profileHelpMessages)}
          />
        </div>
      </section>
    </div>
  );
}
