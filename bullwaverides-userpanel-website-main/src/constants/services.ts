import { ROUTES } from "./routes";

export interface ServiceItem {
  name: string;
  description: string;
  image: string;
  route: string;
}

export const homeServices: ServiceItem[] = [
  { name: "Bike-Taxi", description: "Beat the traffic, save money", image: "/images/services/bike.png", route: `${ROUTES.start}?tab=rides&vehicle=bike` },
  { name: "Electric Auto", description: "No haggling, just easy rides", image: "/images/services/auto.png", route: `${ROUTES.start}?tab=rides&vehicle=auto` },
  { name: "Cab", description: "Comfortable rides for you", image: "/images/services/car.png", route: `${ROUTES.start}?tab=rides&vehicle=cab` },
  { name: "Parcel", description: "Quick, secure & insured deliveries", image: "/images/services/parcel.png", route: `${ROUTES.start}?tab=parcel&vehicle=parcel` },
  { name: "Travel and Stay", description: "One app, all solutions", image: "/images/services/travel.png", route: `${ROUTES.start}?tab=rides&vehicle=travel` },
  { name: "Ambulance", description: "Emergency medical transport", image: "/images/services/ambulance.png", route: ROUTES.ambulance },
];

/** Auth login/signup left panel — reuses home 3D service assets */
export const loginAuthServices = [
  {
    title: "Ride Booking",
    description: "Book bike, auto, cab and e-rickshaw instantly.",
    image: "/images/services/bike.png",
    variant: "default" as const,
  },
  {
    title: "Parcel Delivery",
    description: "Fast and secure package delivery.",
    image: "/images/services/parcel.png",
    variant: "default" as const,
  },
  {
    title: "Emergency Ambulance",
    description: "24/7 emergency medical assistance.",
    image: "/images/services/ambulance.png",
    variant: "ambulance" as const,
  },
  {
    title: "Live Tracking",
    description: "Track every ride in real-time with live updates.",
    image: "/images/features/quick-pickup.png",
    variant: "default" as const,
  },
] as const;

export const landingServices: ServiceItem[] = [
  { name: "Bike-Taxi", description: "Beat the traffic, save money", image: "/images/services/bike.png", route: ROUTES.login },
  { name: "Electric Auto", description: "No haggling, just easy rides", image: "/images/services/auto.png", route: ROUTES.login },
  { name: "Cab", description: "Comfortable rides for you", image: "/images/services/car.png", route: ROUTES.login },
  { name: "Parcel", description: "Quick, secure & insured deliveries", image: "/images/services/parcel.png", route: ROUTES.login },
  { name: "Travel and Stay", description: "One app, all solutions", image: "/images/services/travel.png", route: ROUTES.login },
  { name: "Ambulance", description: "Emergency medical transport", image: "/images/services/ambulance.png", route: ROUTES.ambulance },
];

export const landingHeroImage = "/images/landing/hero-mobility.png";

export const landingHeroSlides = [
  { src: "/images/landing/hero-slide-bike.png", alt: "Bull Wave rides bike taxi ride" },
  { src: "/images/landing/hero-slide-e-auto.png", alt: "Bull Wave rides electric auto ride" },
  { src: "/images/landing/hero-slide-parcel.png", alt: "Bull Wave rides parcel delivery" },
  { src: "/images/landing/hero-slide-fleet.png", alt: "Bull Wave rides mobility fleet" },
  { src: "/images/landing/hero-slide-ambulance.png", alt: "Bull Wave rides ambulance service" },
] as const;
export const landingCaptainImage = "/images/landing/captain-partner.png";

export const landingBookingTabs = [
  { id: "rides", label: "Rides" },
  { id: "parcel", label: "Parcel" },
  { id: "ambulance", label: "Emergency" },
] as const;

export type LandingBookingTab = (typeof landingBookingTabs)[number]["id"];

export const landingFeatures = [
  {
    title: "Quick Pickup",
    desc: "Captains nearby, matched in seconds — not minutes.",
    body: "Bull Wave rides uses smart routing to connect you with the closest available captain the moment you confirm your ride. Whether you're heading to work, catching a flight, or rushing to an appointment, you spend less time waiting on the curb and more time moving.",
    points: [
      "Live captain matching across bike, auto, and cab",
      "Average pickup under 5 minutes in active zones",
      "Real-time ETA updates from booking to arrival",
    ],
    image: "/images/features/quick-pickup.png",
  },
  {
    title: "Best Fares",
    desc: "Upfront pricing with no surprises at the end of your trip.",
    body: "Know your fare before you ride. Bull Wave rides shows a clear price estimate based on distance, time, and demand — so there are no awkward surprises when you reach your destination. What you see is what you pay.",
    points: [
      "Transparent fare breakdown before every trip",
      "No hidden charges or last-minute add-ons",
      "Wallet credits and offers applied automatically",
    ],
    image: "/images/features/best-fares.png",
  },
  {
    title: "Never Too Far",
    desc: "Dense city coverage that keeps you connected wherever you go.",
    body: "From busy city centres to growing suburbs, Bull Wave rides is built to keep you connected. Our captain network spans across neighbourhoods, highways, and key landmarks — so a reliable ride is never more than a few taps away.",
    points: [
      "Wide coverage across 50+ cities and counting",
      "Airport, hospital, and office routes supported",
      "24/7 availability including late-night safety rides",
    ],
    image: "/images/features/never-too-far.png",
  },
] as const;

export const landingNavLinks = [
  { label: "Home", href: ROUTES.landing },
  { label: "Services", href: "#services" },
  { label: "About Us", href: ROUTES.about },
  { label: "Safety", href: ROUTES.safety },
  { label: "Blogs", href: ROUTES.blogs },
  { label: "SOS", href: "#sos" },
  { label: "Captains", href: "#captains" },
] as const;
