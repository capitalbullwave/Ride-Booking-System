import Link from "next/link";
import {
  Ambulance,
  Bike,
  Car,
  ChevronRight,
  Heart,
  MapPin,
  Package,
  ShieldCheck,
  Sparkles,
  Users,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { InfoPageLayout } from "@/components/layout";
import { WaveGoLogo } from "@/components/layout/WaveGoLogo";
import { ROUTES } from "@/constants/routes";

const services = [
  {
    icon: Bike,
    name: "Bike & Auto",
    description: "Quick, affordable rides for everyday city travel.",
  },
  {
    icon: Car,
    name: "Cab",
    description: "Comfortable cars for longer trips and family travel.",
  },
  {
    icon: Package,
    name: "Delivery",
    description: "Send packages across the city with live tracking.",
  },
  {
    icon: Ambulance,
    name: "Ambulance",
    description: "Emergency medical transport when every minute counts.",
  },
] as const;

const values = [
  {
    icon: ShieldCheck,
    title: "Safety first",
    description: "Verified captains, live tracking, and 24/7 support on every trip.",
  },
  {
    icon: Sparkles,
    title: "Simple & premium",
    description: "A clean experience that feels fast, modern, and easy to use.",
  },
  {
    icon: Users,
    title: "Built for everyone",
    description: "Riders, captains, and cities — mobility that works for all of India.",
  },
] as const;

function ServiceCard({
  icon: Icon,
  name,
  description,
}: (typeof services)[number]) {
  return (
    <div className="rounded-[18px] border border-border bg-card p-4 shadow-sm transition-all hover:border-primary/25 hover:shadow-md">
      <div className="mb-3 flex h-10 w-10 items-center justify-center rounded-[12px] bg-secondary/30 text-primary">
        <Icon className="h-5 w-5" />
      </div>
      <p className="font-heading text-sm font-bold text-foreground">{name}</p>
      <p className="mt-1 text-xs leading-relaxed text-muted-foreground">{description}</p>
    </div>
  );
}

function ValueRow({
  icon: Icon,
  title,
  description,
}: (typeof values)[number]) {
  return (
    <div className="flex gap-4 rounded-[18px] border border-border bg-card p-4 shadow-sm">
      <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-[14px] bg-primary/10 text-primary">
        <Icon className="h-5 w-5" />
      </div>
      <div>
        <p className="font-heading text-sm font-bold text-foreground">{title}</p>
        <p className="mt-1 text-sm leading-relaxed text-muted-foreground">{description}</p>
      </div>
    </div>
  );
}

function LinkRow({
  href,
  label,
  description,
  icon: Icon,
}: {
  href: string;
  label: string;
  description: string;
  icon: LucideIcon;
}) {
  return (
    <Link
      href={href}
      className="group flex items-center gap-4 rounded-[18px] border border-border bg-card p-4 shadow-sm transition-all hover:border-primary/30 hover:shadow-md"
    >
      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-[12px] bg-muted text-primary transition-colors group-hover:bg-primary/10">
        <Icon className="h-4 w-4" />
      </div>
      <div className="min-w-0 flex-1">
        <p className="text-sm font-semibold text-foreground">{label}</p>
        <p className="text-xs text-muted-foreground">{description}</p>
      </div>
      <ChevronRight className="h-4 w-4 shrink-0 text-muted-foreground/40 transition-transform group-hover:translate-x-0.5 group-hover:text-primary" />
    </Link>
  );
}

export function AboutView() {
  return (
    <InfoPageLayout title="About Bull Wave rides">
      <div className="max-w-3xl space-y-8">
        {/* Brand intro */}
        <div className="rounded-[24px] border border-border bg-gradient-to-br from-primary/5 via-card to-secondary/10 p-6 shadow-sm">
          <WaveGoLogo size="md" />
          <p className="mt-5 text-sm leading-relaxed text-muted-foreground">
            Bull Wave rides is a premium mobility platform built for seamless travel across your city.
            From quick bike rides and cab bookings to parcel deliveries and emergency ambulance
            support — every way you move, in one beautiful app.
          </p>
          <div className="mt-4 flex items-center gap-2 text-xs font-medium text-muted-foreground">
            <MapPin className="h-3.5 w-3.5 text-primary" />
            Serving riders &amp; captains across India
          </div>
        </div>

        {/* Services */}
        <section>
          <h2 className="mb-3 font-heading text-lg font-bold text-foreground">What we offer</h2>
          <div className="grid gap-3 sm:grid-cols-2">
            {services.map((service) => (
              <ServiceCard key={service.name} {...service} />
            ))}
          </div>
        </section>

        {/* Mission & vision */}
        <section className="grid gap-4 sm:grid-cols-2">
          <div className="rounded-[20px] border border-border bg-card p-5 shadow-sm">
            <div className="mb-2 flex h-9 w-9 items-center justify-center rounded-[12px] bg-primary/10 text-primary">
              <Heart className="h-4 w-4" />
            </div>
            <p className="font-heading font-bold text-foreground">Our mission</p>
            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
              Move smarter. Travel better. Bull Wave rides connects riders and captains with safe,
              reliable, and affordable transportation — whenever and wherever you need it.
            </p>
          </div>
          <div className="rounded-[20px] border border-border bg-card p-5 shadow-sm">
            <div className="mb-2 flex h-9 w-9 items-center justify-center rounded-[12px] bg-secondary/40 text-primary">
              <Sparkles className="h-4 w-4" />
            </div>
            <p className="font-heading font-bold text-foreground">Our vision</p>
            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
              To become India&apos;s most trusted mobility platform — where everyday rides,
              deliveries, and emergency care are just one tap away.
            </p>
          </div>
        </section>

        {/* Values */}
        <section>
          <h2 className="mb-3 font-heading text-lg font-bold text-foreground">Why Bull Wave rides</h2>
          <div className="space-y-3">
            {values.map((value) => (
              <ValueRow key={value.title} {...value} />
            ))}
          </div>
        </section>

        {/* Quick links */}
        <section>
          <h2 className="mb-3 font-heading text-lg font-bold text-foreground">Learn more</h2>
          <div className="space-y-3">
            <LinkRow
              href={ROUTES.safety}
              label="Safety Policy"
              description="How we keep every trip and emergency safe"
              icon={ShieldCheck}
            />
            <LinkRow
              href={ROUTES.profileHelp}
              label="Help & Support"
              description="Get answers or contact our team"
              icon={Users}
            />
          </div>
        </section>

        {/* Version */}
        <div className="rounded-[20px] border border-dashed border-border bg-muted/20 px-5 py-4">
          <div className="flex flex-wrap items-center justify-between gap-2">
            <div>
              <p className="text-sm font-semibold text-foreground">App version</p>
              <p className="text-xs text-muted-foreground">0.1.0 · UI Preview</p>
            </div>
            <p className="text-xs text-muted-foreground">© 2026 Bull Wave rides Technologies</p>
          </div>
        </div>
      </div>
    </InfoPageLayout>
  );
}
