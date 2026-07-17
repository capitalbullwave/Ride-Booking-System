"use client";

import Image from "next/image";
import Link from "next/link";
import { LandingHeroSlider } from "@/components/landing/LandingHeroSlider";
import { useRouter, useSearchParams } from "next/navigation";
import {
  MapPin,
  Navigation2,
} from "lucide-react";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { DownloadAppMenu } from "@/components/landing/DownloadAppMenu";
import { ServiceImage } from "@/components/home/ServiceImage";
import { buildLocationSearchUrl, isLandingBookingTab } from "@/lib/location-search";
import type { LocationFieldType } from "@/lib/location-search";
import { buildBookUrl } from "@/lib/ride-booking";
import { getProtectedPath } from "@/lib/auth-session";
import { LandingHeader } from "@/components/landing/LandingHeader";
import { AnimateIn, Stagger, StaggerItem } from "@/components/motion";
import { WaveGoLogo } from "@/components/layout/WaveGoLogo";
import { WhyWaveGoSection } from "@/components/landing/WhyWaveGoSection";
import { SosSection } from "@/components/landing/SosSection";
import { LandingFaqSection } from "@/components/landing/LandingFaqSection";
import { ROUTES } from "@/constants/routes";
import { APP_DOWNLOAD } from "@/constants/app-download";
import {
  landingBookingTabs,
  landingCaptainImage,
  landingHeroSlides,
  landingServices,
  type LandingBookingTab,
} from "@/constants/services";

function getDropoffLocationCopy(tab: LandingBookingTab) {
  if (tab === "parcel") {
    return {
      title: "Enter delivery address",
      placeholder: "Enter delivery address",
      emptyLabel: "Delivery address",
    };
  }
  if (tab === "ambulance") {
    return {
      title: "Enter hospital or destination",
      placeholder: "Hospital or destination",
      emptyLabel: "Hospital or destination",
    };
  }
  return {
    title: "Enter dropoff location",
    placeholder: "Enter dropoff location",
    emptyLabel: "Dropoff location",
  };
}

export function LandingView() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [activeTab, setActiveTab] = useState<LandingBookingTab>("rides");
  const [pickup, setPickup] = useState("");
  const [dropoff, setDropoff] = useState("");

  const dropoffCopy = getDropoffLocationCopy(activeTab);

  useEffect(() => {
    const urlPickup = searchParams.get("pickup");
    const urlDropoff = searchParams.get("dropoff");
    const urlTab = searchParams.get("tab");

    if (urlPickup) setPickup(urlPickup);
    if (urlDropoff) setDropoff(urlDropoff);
    if (isLandingBookingTab(urlTab)) setActiveTab(urlTab);
  }, [searchParams]);

  const openLocationSearch = (field: LocationFieldType) => {
    router.push(
      buildLocationSearchUrl({
        field,
        returnTo: ROUTES.landing,
        pickup,
        dropoff,
        tab: activeTab,
      })
    );
  };

  const handleBook = (e: React.FormEvent) => {
    e.preventDefault();
    if (activeTab === "ambulance") {
      router.push(getProtectedPath(ROUTES.ambulance));
      return;
    }
    if (!pickup || !dropoff) {
      openLocationSearch(!pickup ? "pickup" : "dropoff");
      return;
    }
    router.push(buildBookUrl(pickup, dropoff, activeTab));
  };

  const ctaLabel =
    activeTab === "rides"
      ? "See prices"
      : activeTab === "parcel"
        ? "Send parcel"
        : "Request ambulance";

  return (
    <div className="min-h-screen bg-background font-sans">
      <LandingHeader />

      {/* Hero + booking widget */}
      <section className="relative bg-background">
        <div className="pointer-events-none absolute inset-0 overflow-hidden bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-secondary/15 via-background to-background" />

        <div className="relative mx-auto grid max-w-7xl gap-10 px-6 py-14 md:grid-cols-[minmax(0,1fr)_minmax(0,1.15fr)] md:items-center md:gap-12 lg:grid-cols-[minmax(0,0.92fr)_minmax(0,1.08fr)] lg:gap-14 lg:py-20">
          <AnimateIn className="relative z-10 max-w-xl">
            <h1 className="font-heading text-4xl font-bold leading-[1.08] tracking-tight text-foreground sm:text-5xl lg:text-[3.25rem]">
              Go anywhere.
              <span className="block text-primary">One wave away.</span>
            </h1>
            <p className="mt-5 max-w-lg text-base leading-relaxed text-muted-foreground sm:text-lg">
              Book rides, send parcels, or request emergency ambulance — all from a single
              premium app built for Indian cities.
            </p>

            <div className="mt-8 max-w-md rounded-2xl border border-border bg-card p-2 shadow-xl shadow-primary/5">
              <div className="flex gap-1 rounded-xl bg-muted/60 p-1">
                {landingBookingTabs.map((tab) => {
                  const isEmergency = tab.id === "ambulance";
                  const isActive = activeTab === tab.id;

                  return (
                    <button
                      key={tab.id}
                      type="button"
                      onClick={() => setActiveTab(tab.id)}
                      className={`flex-1 rounded-lg px-3 py-2.5 text-sm font-semibold transition-all ${
                        isEmergency
                          ? isActive
                            ? "bg-destructive text-white shadow-sm"
                            : "text-destructive hover:bg-destructive/10"
                          : isActive
                            ? "bg-card text-foreground shadow-sm"
                            : "text-muted-foreground hover:text-foreground"
                      }`}
                    >
                      {tab.label}
                    </button>
                  );
                })}
              </div>

              <form onSubmit={handleBook} className="space-y-3 p-3 pt-4">
                <button
                  type="button"
                  onClick={() => openLocationSearch("pickup")}
                  className="flex w-full items-center gap-3 rounded-xl border border-border bg-muted/30 px-4 py-3 text-left transition-colors hover:border-primary/40 hover:bg-card focus-visible:border-primary focus-visible:bg-card focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/20"
                >
                  <Navigation2 className="h-4 w-4 shrink-0 text-primary" />
                  <span
                    className={`truncate text-base ${
                      pickup
                        ? "font-medium text-foreground"
                        : "text-muted-foreground"
                    }`}
                  >
                    {pickup || "Pickup location"}
                  </span>
                </button>
                <button
                  type="button"
                  onClick={() => openLocationSearch("dropoff")}
                  className="flex w-full items-center gap-3 rounded-xl border border-border bg-muted/30 px-4 py-3 text-left transition-colors hover:border-primary/40 hover:bg-card focus-visible:border-primary focus-visible:bg-card focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/20"
                >
                  <MapPin className="h-4 w-4 shrink-0 text-destructive" />
                  <span
                    className={`truncate text-base ${
                      dropoff
                        ? "font-medium text-foreground"
                        : "text-muted-foreground"
                    }`}
                  >
                    {dropoff || dropoffCopy.emptyLabel}
                  </span>
                </button>
                <Button
                  type="submit"
                  className={`h-12 w-full rounded-xl text-base font-bold ${
                    activeTab === "ambulance"
                      ? "bg-destructive hover:bg-destructive/90"
                      : ""
                  }`}
                >
                  {ctaLabel}
                </Button>
              </form>
            </div>
          </AnimateIn>

          <AnimateIn delay={0.1} className="relative z-0 min-w-0 w-full overflow-hidden px-2 sm:px-3 md:px-4">
            <LandingHeroSlider slides={landingHeroSlides} />
          </AnimateIn>
        </div>
      </section>

      {/* Services — compact strip */}
      <section id="services" className="scroll-mt-20 px-6 py-12">
        <AnimateIn>
        <div className="mx-auto max-w-6xl">
          <div className="mb-5 flex items-end justify-between gap-4">
            <div>
              <h2 className="font-heading text-2xl font-bold text-foreground">Our services</h2>
              <p className="mt-1 text-sm text-muted-foreground">
                Tap a service to get started
              </p>
            </div>
            <button
              type="button"
              onClick={() => router.push(ROUTES.login)}
              className="hidden shrink-0 text-sm font-semibold text-primary hover:underline sm:block"
            >
              View all
            </button>
          </div>

          <Stagger className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {landingServices.map((service, index) => {
              const isAmbulance = service.name === "Ambulance";
              return (
                <StaggerItem key={service.name} index={index}>
                <button
                  onClick={() =>
                    router.push(
                      isAmbulance
                        ? getProtectedPath(ROUTES.ambulance)
                        : service.route
                    )
                  }
                  className={`group flex w-full items-center justify-between gap-4 rounded-xl p-5 text-left transition-colors sm:p-6 ${
                    isAmbulance
                      ? "bg-destructive/[0.04] hover:bg-destructive/[0.07]"
                      : "bg-muted/40 hover:bg-muted/55"
                  }`}
                >
                  <div className="min-w-0 flex-1">
                    <p
                      className={`text-lg font-bold leading-tight ${
                        isAmbulance ? "text-destructive" : "text-foreground"
                      }`}
                    >
                      {service.name}
                    </p>
                    <p className="mt-1 text-sm text-muted-foreground">
                      {service.description}
                    </p>
                  </div>
                  <div className="relative h-28 w-28 shrink-0 overflow-hidden rounded-xl bg-muted/15">
                    <ServiceImage
                      src={service.image}
                      alt={service.name}
                      imageClassName="scale-[1.7] p-0"
                    />
                  </div>
                </button>
                </StaggerItem>
              );
            })}
          </Stagger>
        </div>
        </AnimateIn>
      </section>

      <WhyWaveGoSection />

      <SosSection />

      {/* Captains */}
      <section id="captains" className="scroll-mt-20 px-6 py-20">
        <AnimateIn>
        <div className="relative mx-auto max-w-6xl overflow-hidden rounded-[2rem] bg-primary px-8 py-10 shadow-xl shadow-primary/20 lg:px-12 lg:py-14">
          <div className="absolute -right-16 -top-16 h-56 w-56 rounded-full bg-white/10 blur-3xl" />
          <div className="absolute -bottom-20 left-10 h-48 w-48 rounded-full bg-secondary/25 blur-3xl" />

          <div className="relative grid items-center gap-10 lg:grid-cols-[1.1fr_0.9fr] lg:gap-14">
            <div className="flex flex-col gap-5 text-white">
              <p className="inline-flex w-fit rounded-full bg-white/10 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-secondary">
                Drive with Bull Wave Rides
              </p>
              <h2 className="font-heading text-3xl font-bold leading-tight sm:text-4xl">
                Earn on your terms.
                <span className="block text-secondary">Drive with pride.</span>
              </h2>
              <p className="max-w-md leading-relaxed text-white/80">
                Set your own schedule, get transparent payouts, and partner with a platform that
                invests in captain safety and support.
              </p>
              <ul className="space-y-2 text-sm text-white/85">
                <li className="flex items-center gap-2">
                  <span className="h-1.5 w-1.5 rounded-full bg-secondary" />
                  Flexible hours — you choose when to drive
                </li>
                <li className="flex items-center gap-2">
                  <span className="h-1.5 w-1.5 rounded-full bg-secondary" />
                  Weekly payouts with zero hidden fees
                </li>
                <li className="flex items-center gap-2">
                  <span className="h-1.5 w-1.5 rounded-full bg-secondary" />
                  24/7 captain support &amp; safety tools
                </li>
              </ul>
              <DownloadAppMenu
                size="lg"
                label="Download Captain App"
                buttonClassName="mt-2 h-12 w-fit rounded-xl bg-secondary px-8 font-bold text-primary hover:bg-white"
                androidApkUrl={APP_DOWNLOAD.captainAndroidApkUrl}
                androidFileName={APP_DOWNLOAD.captainAndroidFileName}
                iosUrl={APP_DOWNLOAD.captainIosAppStoreUrl}
              />
            </div>

            <div className="relative mx-auto w-full max-w-sm lg:max-w-none lg:translate-y-2">
              <div className="relative aspect-[5/4] overflow-hidden rounded-2xl shadow-2xl ring-2 ring-white/15">
                <Image
                  src={landingCaptainImage}
                  alt="Bull Wave Rides captain partner"
                  fill
                  className="object-cover"
                  sizes="(max-width: 1024px) 100vw, 40vw"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-primary/40 via-transparent to-transparent" />
              </div>
            </div>
          </div>
        </div>
        </AnimateIn>
      </section>

      <LandingFaqSection />

      {/* Footer + App download */}
      <footer className="bg-background">
        <AnimateIn>
        <div className="border-t border-border px-6 py-16">
          <div className="mx-auto max-w-6xl overflow-hidden rounded-[1.75rem] bg-primary shadow-xl shadow-primary/15">
            <div className="grid items-center gap-8 px-8 py-10 lg:grid-cols-[1.2fr_auto] lg:gap-12 lg:px-12 lg:py-12">
              <div className="text-white">
                <p className="text-xs font-bold uppercase tracking-widest text-secondary">
                  Download
                </p>
                <h2 className="mt-2 font-heading text-2xl font-bold sm:text-3xl">
                  Get the Bull Wave Rides app
                </h2>
                <p className="mt-3 max-w-md text-sm leading-relaxed text-white/80 sm:text-base">
                  Book rides, track trips, send parcels, and access emergency SOS — everything
                  you need in one premium app.
                </p>
              </div>
              <div className="flex flex-col gap-3 sm:flex-row lg:flex-col xl:flex-row">
                <Button
                  size="lg"
                  className="h-12 min-w-[160px] justify-center rounded-xl bg-white px-6 font-bold text-primary hover:bg-secondary"
                  onClick={() => router.push(ROUTES.login)}
                >
                  App Store
                </Button>
                <Button
                  size="lg"
                  variant="outline"
                  className="h-12 min-w-[160px] justify-center rounded-xl border-white/40 bg-white/5 px-6 font-bold text-white hover:bg-white/15"
                  onClick={() => router.push(ROUTES.login)}
                >
                  Google Play
                </Button>
              </div>
            </div>
          </div>
        </div>
        </AnimateIn>

        <AnimateIn delay={0.08}>
        <div className="border-t border-border bg-card px-6 py-14">
          <div className="mx-auto max-w-6xl">
            <div className="grid gap-10 sm:grid-cols-2 lg:grid-cols-4">
              <div className="sm:col-span-2 lg:col-span-1">
                <WaveGoLogo size="md" />
                <p className="mt-4 max-w-xs text-sm leading-relaxed text-muted-foreground">
                  Premium rides, smart deliveries, and emergency ambulance — one elegant mobility
                  platform for modern India.
                </p>
              </div>

              <div>
                <p className="mb-4 text-sm font-bold text-foreground">Explore</p>
                <nav className="flex flex-col gap-3 text-sm text-muted-foreground">
                  <Link href="#services" className="transition-colors hover:text-primary">
                    Services
                  </Link>
                  <Link href="#why-wavego" className="transition-colors hover:text-primary">
                    Why Bull Wave Rides
                  </Link>
                  <Link href="#captains" className="transition-colors hover:text-primary">
                    Become a captain
                  </Link>
                  <Link href="#faqs" className="transition-colors hover:text-primary">
                    FAQs
                  </Link>
                </nav>
              </div>

              <div>
                <p className="mb-4 text-sm font-bold text-foreground">Support</p>
                <nav className="flex flex-col gap-3 text-sm text-muted-foreground">
                  <Link
                    href={getProtectedPath(ROUTES.profileHelp)}
                    className="transition-colors hover:text-primary"
                  >
                    Help center
                  </Link>
                  <Link
                    href={getProtectedPath(ROUTES.ambulance)}
                    className="transition-colors hover:text-primary"
                  >
                    Ambulance SOS
                  </Link>
                  <Link href={ROUTES.about} className="transition-colors hover:text-primary">
                    About us
                  </Link>
                  <Link href={ROUTES.blogs} className="transition-colors hover:text-primary">
                    Blog
                  </Link>
                </nav>
              </div>

              <div>
                <p className="mb-4 text-sm font-bold text-foreground">Legal</p>
                <nav className="flex flex-col gap-3 text-sm text-muted-foreground">
                  <Link href={ROUTES.terms} className="transition-colors hover:text-primary">
                    Terms of service
                  </Link>
                  <Link href={ROUTES.privacy} className="transition-colors hover:text-primary">
                    Privacy policy
                  </Link>
                  <Link href={ROUTES.safety} className="transition-colors hover:text-primary">
                    Safety policy
                  </Link>
                </nav>
              </div>
            </div>

            <div className="mt-12 flex flex-col items-center justify-between gap-4 border-t border-border pt-8 text-sm text-muted-foreground sm:flex-row">
              <p>© 2026 Bull Wave Rides Technologies. All rights reserved.</p>
              <p className="text-xs">Made for riders, captains &amp; cities across India.</p>
            </div>
          </div>
        </div>
        </AnimateIn>
      </footer>
    </div>
  );
}

