import type { LucideIcon } from "lucide-react";
import {
  Headphones,
  Lock,
  MapPin,
  Phone,
  Share2,
  Shield,
  Siren,
  Smartphone,
  Star,
  UserCheck,
  Users,
} from "lucide-react";
import { ROUTES } from "@/constants/routes";
import { landingCaptainImage, landingHeroSlides } from "@/constants/services";

/** Customer-focused assets (riders, booking, trip experience) */
const customerImages = {
  quickPickup: "/images/features/quick-pickup.png",
  rideConfirmed: "/images/feature_pickup.png",
  familyRide: landingHeroSlides[1].src,
  bikePassenger: landingHeroSlides[0].src,
  ambulance: landingHeroSlides[4].src,
} as const;

/** Captain-focused assets (partners, fleet, delivery) */
const captainImages = {
  partner: landingCaptainImage,
  partnerIllustration: "/images/captain_cta.png",
  fleet: landingHeroSlides[3].src,
  delivery: landingHeroSlides[2].src,
} as const;

export const safetyHeroImages = [
  {
    src: landingHeroSlides[0].src,
    alt: "Bull Wave Rides rider on a bike taxi",
    className: "left-0 top-8 z-10 h-36 w-32 sm:h-40 sm:w-36",
  },
  {
    src: landingHeroSlides[1].src,
    alt: "Bull Wave Rides customer on electric auto",
    className: "left-1/2 top-0 z-20 h-40 w-32 -translate-x-1/2 sm:h-44 sm:w-36",
  },
  {
    src: landingCaptainImage,
    alt: "Happy Bull Wave Rides captain and customer",
    className: "right-0 top-10 z-10 h-36 w-32 sm:h-40 sm:w-36",
  },
] as const;

export const coversEveryoneCards = [
  {
    id: "customers",
    title: "For Customers",
    description:
      "Every ride is protected through live tracking, verified captain information, emergency support, and trip-sharing features designed to keep you safe.",
    image: customerImages.quickPickup,
    alt: "Bull Wave Rides customer safety",
    tab: "customer" as const,
  },
  {
    id: "captains",
    title: "For Captains",
    description:
      "Bull Wave Rides supports captains with verification systems, safety training, emergency support tools, and fair platform policies.",
    image: captainImages.partner,
    alt: "Bull Wave Rides captain safety",
    tab: "captain" as const,
  },
] as const;

export const safetyMeasures = [
  {
    icon: Shield,
    title: "Insurance Protection",
    description:
      "Eligible rides are covered through ride protection programs and safety initiatives.",
  },
  {
    icon: Headphones,
    title: "24×7 Customer Support",
    description:
      "Our support team is available around the clock to assist riders and drivers.",
  },
  {
    icon: Star,
    title: "Two-Way Rating System",
    description:
      "Both riders and drivers can rate each other, helping maintain a respectful and trustworthy community.",
  },
  {
    icon: UserCheck,
    title: "Verified Profiles",
    description:
      "All drivers undergo document and identity verification before joining the platform.",
  },
] as const;

/** First three measures shown on the overview 2×2 grid */
export const safetyOverviewMeasures = safetyMeasures.slice(0, 3);

export const safetyFeatureCards: {
  icon: LucideIcon;
  title: string;
  description: string;
}[] = [
  {
    icon: Shield,
    title: "Verified Drivers",
    description: "Identity and document verification before activation.",
  },
  {
    icon: MapPin,
    title: "Live Trip Tracking",
    description: "Track rides in real-time from pickup to destination.",
  },
  {
    icon: Siren,
    title: "SOS Emergency Assistance",
    description: "Get immediate access to emergency support.",
  },
  {
    icon: Phone,
    title: "Emergency Contact Sharing",
    description: "Share ride details with trusted contacts.",
  },
  {
    icon: Star,
    title: "Community Rating System",
    description: "Maintain quality and accountability through ratings.",
  },
  {
    icon: Lock,
    title: "Privacy & Data Protection",
    description: "Your personal information remains secure and protected.",
  },
];

export const protectionSteps = [
  {
    step: 1,
    title: "Driver Verification",
    description: "Document checks, identity verification, and vehicle inspection before onboarding.",
  },
  {
    step: 2,
    title: "Ride Monitoring",
    description: "Trips are monitored for route deviations and unusual activity patterns.",
  },
  {
    step: 3,
    title: "Live Tracking",
    description: "Real-time GPS from booking to drop-off for riders and shared contacts.",
  },
  {
    step: 4,
    title: "Emergency Support",
    description: "One-tap SOS and 24×7 safety team response during critical situations.",
  },
  {
    step: 5,
    title: "Post-Ride Feedback",
    description: "Two-way ratings and incident reporting to improve every future trip.",
  },
] as const;

export const safetyFaqItems = [
  {
    id: "verify",
    question: "How does Bull Wave Rides verify drivers?",
    answer:
      "Every captain submits government ID, driving license, vehicle documents, and passes background screening. Profiles are re-verified periodically to maintain platform standards.",
  },
  {
    id: "share",
    question: "How can I share my ride with family?",
    answer:
      "During an active trip, tap Share trip to send a live tracking link to trusted contacts via SMS or messaging apps.",
  },
  {
    id: "emergency",
    question: "What should I do in an emergency?",
    answer:
      "Use in-app SOS for immediate Bull Wave Rides support. For life-threatening situations, call local emergency services first, then report the incident through Help & Support.",
  },
  {
    id: "sos",
    question: "How does the SOS feature work?",
    answer:
      "SOS connects you to Bull Wave Rides's safety team with your live location and trip details. The team can coordinate with local authorities when required.",
  },
  {
    id: "privacy",
    question: "Is my personal data secure?",
    answer:
      "Bull Wave Rides encrypts personal data and follows our Privacy Policy. Trip data is used for safety, support, and service improvement — never sold to third parties.",
  },
  {
    id: "report",
    question: "How can I report a safety issue?",
    answer:
      "Open Help & Support from the app menu, select Report Issue, and share trip details. Our trust & safety team reviews reports within 24 hours.",
  },
] as const;

export const safetyFooterLinks = {
  company: [
    { label: "About Bull Wave Rides", href: ROUTES.about },
    { label: "Safety", href: ROUTES.safety },
    { label: "Contact Us", href: ROUTES.profileHelp },
    { label: "Careers", href: ROUTES.landing + "#captains" },
  ],
  legal: [
    { label: "Privacy Policy", href: ROUTES.privacy },
    { label: "Terms & Conditions", href: ROUTES.terms },
    { label: "Community Guidelines", href: ROUTES.safety },
  ],
} as const;

export const safetySocialLinks = [
  { label: "Facebook", href: "#", icon: "facebook" as const },
  { label: "Twitter", href: "#", icon: "twitter" as const },
  { label: "LinkedIn", href: "#", icon: "linkedin" as const },
  { label: "Instagram", href: "#", icon: "instagram" as const },
];

export type SafetyAudience = "all" | "customer" | "captain";

export const safetyTabs: { id: SafetyAudience; label: string }[] = [
  { id: "all", label: "Overview" },
  { id: "customer", label: "Customer" },
  { id: "captain", label: "Captain" },
];

const customerHeroImages = [
  {
    src: customerImages.quickPickup,
    alt: "Bull Wave Rides customer booking a ride on the app",
    className: "left-2 top-6 z-10 h-36 w-32 sm:h-40 sm:w-36",
  },
  {
    src: customerImages.familyRide,
    alt: "Bull Wave Rides family riding in electric auto",
    className: "left-1/2 top-0 z-20 h-40 w-32 -translate-x-1/2 sm:h-44 sm:w-36",
  },
  {
    src: customerImages.bikePassenger,
    alt: "Bull Wave Rides customer on a bike taxi",
    className: "right-0 top-10 z-10 h-36 w-32 sm:h-40 sm:w-36",
  },
] as const;

const captainHeroImages = [
  {
    src: captainImages.partner,
    alt: "Bull Wave Rides captain partner with vehicle",
    className: "left-0 top-8 z-10 h-36 w-32 sm:h-40 sm:w-36",
  },
  {
    src: captainImages.fleet,
    alt: "Bull Wave Rides captain fleet on the road",
    className: "left-1/2 top-0 z-20 h-40 w-32 -translate-x-1/2 sm:h-44 sm:w-36",
  },
  {
    src: captainImages.delivery,
    alt: "Bull Wave Rides delivery captain with parcel",
    className: "right-0 top-10 z-10 h-36 w-32 sm:h-40 sm:w-36",
  },
] as const;

export const safetyTabContent = {
  all: {
    heroTitle: "Safety for Everyone.",
    heroDescription:
      "At Bull Wave Rides, your safety is our highest priority. From verified drivers and real-time ride tracking to emergency assistance and 24×7 support, we are committed to making every journey secure, reliable, and comfortable.",
    heroImages: safetyHeroImages,
    highlightsTitle: "Covers Everyone",
    highlights: [
      {
        title: "For Riders",
        description:
          "Every ride is protected through live tracking, verified driver information, emergency support, and trip-sharing features designed to keep you safe.",
        image: landingHeroSlides[1].src,
        alt: "Bull Wave Rides rider safety",
      },
      {
        title: "For Captains",
        description:
          "Bull Wave Rides supports captains with verification systems, safety training, emergency support tools, and fair platform policies.",
        image: landingCaptainImage,
        alt: "Bull Wave Rides captain safety",
      },
      {
        title: "Emergency Support",
        description:
          "Ambulance rides with verified medical transport captains and 24×7 emergency assistance when every second counts.",
        image: landingHeroSlides[4].src,
        alt: "Bull Wave Rides ambulance safety",
      },
    ],
    measuresHeading: "Measures to ensure the well-being of both Riders and Drivers.",
    measures: safetyMeasures,
    features: safetyFeatureCards,
    steps: protectionSteps,
    faq: safetyFaqItems,
  },
  customer: {
    heroTitle: "Safety for Customers.",
    heroDescription:
      "At Bull Wave Rides, the well-being of our customers is above everything else. We constantly enhance safety measures — live tracking, verified captains, SOS support, and trip sharing — so every ride is secure and comfortable.",
    heroImages: customerHeroImages,
    highlightsTitle: "Built for riders",
    highlights: [
      {
        title: "Share live trip",
        description: "Send your real-time route to family or friends in one tap.",
        image: customerImages.rideConfirmed,
        alt: "Customer sharing live trip from the app",
      },
      {
        title: "In-app SOS",
        description: "Emergency assistance available throughout your active ride.",
        image: customerImages.ambulance,
        alt: "Bull Wave Rides emergency ambulance support",
      },
      {
        title: "Verified captains",
        description: "See captain and vehicle details before you board every trip.",
        image: customerImages.familyRide,
        alt: "Verified Bull Wave Rides captain with passengers",
      },
    ],
    measuresHeading: "Measures to ensure the well-being of our customers.",
    measures: [
      {
        icon: MapPin,
        title: "Live Trip Tracking",
        description: "Track your ride in real-time from pickup to destination.",
      },
      {
        icon: Siren,
        title: "SOS Emergency Assistance",
        description: "One-tap access to Bull Wave Rides safety support during active trips.",
      },
      {
        icon: Phone,
        title: "Emergency Contact Sharing",
        description: "Share ride details instantly with trusted contacts.",
      },
      {
        icon: UserCheck,
        title: "Verified Captains",
        description: "Every captain is verified before they can accept rides.",
      },
    ],
    features: safetyFeatureCards.slice(0, 6),
    steps: protectionSteps,
    faq: safetyFaqItems.filter((item) =>
      ["share", "emergency", "sos", "privacy", "report"].includes(item.id)
    ),
  },
  captain: {
    heroTitle: "Safety for Captains.",
    heroDescription:
      "Captains are the backbone of Bull Wave Rides. We provide verification support, safety training, emergency tools, fair policies, and 24×7 assistance — so you can focus on safe, reliable rides every day.",
    heroImages: captainHeroImages,
    highlightsTitle: "Built for captains",
    highlights: [
      {
        title: "Safety training",
        description: "Mandatory onboarding and refresher courses every six months.",
        image: captainImages.partnerIllustration,
        alt: "Bull Wave Rides captain in professional uniform",
      },
      {
        title: "Fatigue guidelines",
        description: "Rest reminders and shift limits to prevent tired driving.",
        image: captainImages.fleet,
        alt: "Bull Wave Rides captains on the road",
      },
      {
        title: "Captain helpline",
        description: "Dedicated 24×7 support for on-road safety concerns.",
        image: captainImages.partner,
        alt: "Bull Wave Rides captain partner support",
      },
    ],
    measuresHeading: "Measures to ensure the well-being of our captains.",
    measures: [
      {
        icon: Shield,
        title: "Insurance Guidance",
        description: "Support for vehicle insurance and accident reporting procedures.",
      },
      {
        icon: Headphones,
        title: "24×7 Captain Support",
        description: "Dedicated helpline for captains facing safety issues on the road.",
      },
      {
        icon: Star,
        title: "Two-Way Rating System",
        description: "Rate riders and report incidents to maintain a respectful community.",
      },
      {
        icon: UserCheck,
        title: "Fair Verification",
        description: "Transparent onboarding with document checks and re-verification cycles.",
      },
    ],
    features: [
      {
        icon: Shield,
        title: "Verified Onboarding",
        description: "Document checks and background screening before activation.",
      },
      {
        icon: Headphones,
        title: "Captain Helpline",
        description: "Round-the-clock support for road safety concerns.",
      },
      {
        icon: Star,
        title: "Community Ratings",
        description: "Two-way feedback to maintain platform quality.",
      },
      {
        icon: MapPin,
        title: "Route Assistance",
        description: "Navigation and trip monitoring tools for safer rides.",
      },
      {
        icon: Lock,
        title: "Data Protection",
        description: "Captain personal information kept secure and private.",
      },
      {
        icon: Siren,
        title: "Emergency Tools",
        description: "SOS and incident reporting built into the captain app.",
      },
    ],
    steps: [
      {
        step: 1,
        title: "Captain Verification",
        description: "ID, license, and vehicle documents verified before going online.",
      },
      {
        step: 2,
        title: "Safety Training",
        description: "Mandatory courses on road safety, customer care, and emergency response.",
      },
      {
        step: 3,
        title: "On-Road Monitoring",
        description: "Trip monitoring and support tools available throughout every ride.",
      },
      {
        step: 4,
        title: "Emergency Support",
        description: "24×7 captain helpline and SOS coordination when needed.",
      },
      {
        step: 5,
        title: "Continuous Review",
        description: "Periodic re-verification and performance reviews to maintain standards.",
      },
    ],
    faq: safetyFaqItems.filter((item) =>
      ["verify", "emergency", "report", "privacy"].includes(item.id)
    ),
  },
} as const;

/** Rapido-style safety overview (All tab) layout */
export const safetyOverviewPage = {
  hero: {
    title: "Safety for all.",
    description:
      "At Bull Wave Rides, the well-being of our customers and captains is above everything else. We constantly enhance our safety technologies and processes so every ride is secure, reliable, and comfortable.",
    images: [
      {
        src: customerImages.quickPickup,
        alt: "Bull Wave Rides customer booking a ride",
        className: "left-0 top-8 z-10 h-36 w-32 sm:h-40 sm:w-36",
      },
      {
        src: landingHeroSlides[0].src,
        alt: "Bull Wave Rides captain and customer on bike",
        className: "left-1/2 top-0 z-20 h-40 w-32 -translate-x-1/2 sm:h-44 sm:w-36",
      },
      {
        src: landingCaptainImage,
        alt: "Bull Wave Rides captain partner",
        className: "right-0 top-10 z-10 h-36 w-32 sm:h-40 sm:w-36",
      },
    ],
  },
  coversEveryone: {
    title: "Covers Everyone",
    cards: coversEveryoneCards,
  },
  measures: {
    heading:
      "Measures to ensure the well-being of both, our Captains and Customers.",
    items: safetyOverviewMeasures,
  },
  wayForward: {
    title: "Way forward on Safety",
    description:
      "We are continuously working on new safety features — smarter route monitoring, enhanced SOS response, and improved verification — to make every Bull Wave Rides trip safer.",
    linkLabel: "KNOW MORE",
    href: ROUTES.profileHelp,
  },
} as const;

/** Rapido-style customer safety page layout */
export const customerSafetyPage = {
  hero: {
    title: "Customers Safety",
    description:
      "At Bull Wave Rides, the well-being of our customers is above everything else. We constantly enhance our safety technologies and processes — live tracking, verified captains, SOS support, and trip sharing — so every ride is secure and comfortable.",
    image: customerImages.quickPickup,
    alt: "Bull Wave Rides customer booking a safe ride",
  },
  captainVerification: {
    title: "Captain Verification",
    description:
      "At Bull Wave Rides, the safety and security of our customers is of utmost importance. We have a zero-tolerance policy towards captains who violate our community guidelines. Every captain undergoes a thorough background check and verification before joining the platform.",
    image: captainImages.partner,
    alt: "Verified Bull Wave Rides captain partner",
    accordion: [
      {
        id: "hiring",
        title: "Hiring Process",
        content:
          "Captains apply through the Bull Wave Rides partner app with valid ID, driving license, and vehicle documents. Our team reviews each application before scheduling onboarding.",
      },
      {
        id: "third-party",
        title: "Verification through third party vendor",
        content:
          "We partner with trusted third-party agencies for criminal background checks, address verification, and document authentication before a captain is approved.",
      },
      {
        id: "training",
        title: "Captain Training Process",
        content:
          "Every captain completes mandatory safety training covering road rules, customer care, emergency response, and platform policies before their first ride.",
      },
      {
        id: "monitoring",
        title: "Captain Monitoring Process",
        content:
          "Trips are monitored for route deviations and unusual patterns. Ratings, incident reports, and periodic audits help us maintain high safety standards.",
      },
      {
        id: "retention",
        title: "Captain Retention Process",
        content:
          "Captains must maintain minimum ratings and follow community guidelines. Underperforming or non-compliant partners are retrained or removed from the platform.",
      },
    ],
  },
  appFeatures: {
    title: "App Safety Features",
    features: [
      {
        icon: Share2,
        title: "Trip Sharing",
        description:
          "Share your live trip status with family and friends. They can track your route in real time until you reach your destination safely.",
      },
      {
        icon: Smartphone,
        title: "Information Masking",
        description:
          "Your phone number is masked during calls with captains. Personal contact details stay private throughout the ride.",
      },
      {
        icon: Siren,
        title: "SOS Button",
        description:
          "One-tap SOS connects you to Bull Wave Rides's safety team with your live location and trip details during an active ride.",
      },
      {
        icon: UserCheck,
        title: "Captain Information",
        description:
          "Before every ride, view verified captain and vehicle details so you know exactly who is picking you up.",
        bullets: [
          "Captain Name",
          "Vehicle number",
          "Vehicle Model",
          "Driving Record",
          "Rating",
        ],
      },
      {
        icon: Users,
        title: "On ground support",
        description:
          "Our safety and support teams are available 24×7 to assist with emergencies, incidents, and ride-related concerns.",
      },
    ],
  },
  wayForward: {
    title: "Way forward on Safety",
    description:
      "We are continuously working on new safety features — smarter route monitoring, enhanced SOS response, and improved verification — to make every Bull Wave Rides trip safer.",
    linkLabel: "KNOW MORE",
    href: ROUTES.profileHelp,
  },
} as const;

/** Rapido-style captain safety page layout */
export const captainSafetyPage = {
  hero: {
    title: "Captains Safety",
    description:
      "At Bull Wave Rides, every captain on the road matters. All active rides are insured — with accidental coverage and medical benefits up to ₹5 Lakh for you and your family. From OPD treatment and hospitalisation to emergency support, we stand behind our partners so you can ride with confidence, every single trip.",
    image: customerImages.bikePassenger,
    alt: "Bull Wave Rides captain on a bike taxi",
  },
  measures: {
    heading:
      "Measures to ensure the well-being of both, our Captains and Customers.",
    items: [
      {
        icon: Shield,
        title: "Insurance",
        description:
          "Insurance can be claimed for any accident that occurs during the ride covering OPD treatment, hospitalisation, and accidental benefit with a maximum sum insured of ₹5 Lakh. Claims can be initiated as soon as the ride ends through the Bull Wave Rides captain app.",
      },
      {
        icon: Headphones,
        title: "24×7 Customer Support",
        description:
          "Both our captains and customers can report any kind of issues to Bull Wave Rides through the 24×7 support feature on the app during and after the ride.",
      },
      {
        icon: Star,
        title: "Two-way Rating System",
        description:
          "After every ride, both parties can rate each other. Any rating below 3 is flagged by Bull Wave Rides — our team reaches out within 10 minutes to address concerns. Captains are removed immediately in case of misconduct.",
      },
    ],
  },
} as const;
