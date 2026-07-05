import { ROUTES } from "@/constants/routes";
import type { HelpArticle } from "./help-center";

export const accountSignInHub: HelpArticle = {
  id: "sign-in-access",
  title: "Sign-in and access",
  kind: "hub",
  children: [
    {
      id: "cant-sign-in",
      title: "Can't sign in or request a trip",
      kind: "content",
      paragraphs: [
        "Verify your phone number and OTP. Ensure you have a stable internet connection.",
        "If issues persist, try logging out and signing in again, or contact support.",
      ],
    },
  ],
};

export const accountProfileHub: HelpArticle = {
  id: "profile-settings",
  title: "Profile and settings",
  kind: "hub",
  children: [
    {
      id: "account-settings",
      title: "Account settings",
      kind: "content",
      paragraphs: [
        "Update your name, phone number, email, and language preferences in Account Settings.",
      ],
      link: { label: "Open Account Settings", href: ROUTES.profileAccountSettings },
    },
    {
      id: "lost-phone",
      title: "I lost my phone in Fast Bull",
      kind: "content",
      paragraphs: [
        "Select the relevant trip in Bookings and report a lost phone.",
        "We'll help you contact the captain. Have your account verified for faster support.",
      ],
    },
  ],
};

export const accountPaymentsHub: HelpArticle = {
  id: "payments-billing",
  title: "Payments and billing",
  kind: "hub",
  children: [
    {
      id: "payment-methods",
      title: "Payment methods",
      kind: "content",
      paragraphs: [
        "Add or manage cash, UPI, cards, and Fast Bull Wallet from the Wallet page.",
      ],
      link: { label: "Open Wallet", href: ROUTES.wallet },
    },
    {
      id: "duplicate-charges",
      title: "Duplicate or unknown charges",
      kind: "content",
      paragraphs: [
        "Pending authorizations may appear temporarily and disappear within a few days.",
        "Report unknown charges with your trip receipt via Help & Support.",
      ],
    },
    {
      id: "gift-cards",
      title: "Gift cards and vouchers",
      kind: "content",
      paragraphs: [
        "Redeem gift cards in Wallet. Enter the code under Fast Bull Cash to add balance.",
      ],
    },
    {
      id: "promos",
      title: "Promos and partnerships",
      kind: "content",
      paragraphs: [
        "Apply promo codes at checkout before confirming your booking.",
        "Each promo has specific terms, expiry dates, and service restrictions.",
      ],
    },
    {
      id: "wavego-cash",
      title: "Fast Bull Cash",
      kind: "content",
      paragraphs: [
        "Fast Bull Cash is your in-app wallet balance for rides and deliveries.",
        "Top up, view history, and manage refunds from the Wallet tab.",
      ],
      link: { label: "Open Wallet", href: ROUTES.wallet },
    },
    {
      id: "receipts",
      title: "Receipts and invoices",
      kind: "content",
      paragraphs: [
        "Trip receipts are available in Bookings for completed trips.",
        "Email copies can be requested from the trip details screen.",
      ],
    },
  ],
};

export const safetyPolicyHub: HelpArticle = {
  id: "safety-policy",
  title: "Safety Policy",
  kind: "hub",
  children: [
    {
      id: "read-safety-policy",
      title: "Read Safety Policy",
      kind: "content",
      paragraphs: [
        "Learn how Fast Bull protects riders, captains, and patients on every trip and emergency request.",
      ],
      link: { label: "Open full Safety Policy", href: ROUTES.safety },
    },
    {
      id: "in-app-safety-tools",
      title: "In-app safety tools",
      kind: "content",
      paragraphs: [
        "Share live location, contact support, and access SOS options from the tracking screen during active trips.",
      ],
    },
  ],
};

export const emergencyAssistanceHub: HelpArticle = {
  id: "emergency-assistance",
  title: "Emergency assistance",
  kind: "hub",
  children: [
    {
      id: "request-ambulance",
      title: "Request an ambulance",
      kind: "content",
      paragraphs: [
        "Book emergency medical transport through Fast Bull Ambulance. For life-threatening situations, also call 112.",
      ],
      link: { label: "Open Ambulance SOS", href: ROUTES.ambulance },
    },
    {
      id: "report-emergency-issue",
      title: "Report an emergency issue",
      kind: "content",
      paragraphs: [
        "If something went wrong during an emergency booking, contact support immediately with your trip ID.",
      ],
    },
  ],
};

export const tripSafetyHelpHub: HelpArticle = {
  id: "trip-safety-help",
  title: "Safety during a trip",
  kind: "hub",
  children: [
    {
      id: "share-trip",
      title: "Share trip with contacts",
      kind: "content",
      paragraphs: [
        "Use Share Trip from the live tracking screen to send your route and ETA to family or friends.",
      ],
    },
    {
      id: "report-safety-incident",
      title: "Report a safety incident",
      kind: "content",
      paragraphs: [
        "If you felt unsafe during a ride, report the incident from Bookings or contact support immediately.",
      ],
    },
  ],
};

export const guidesGettingStartedHub: HelpArticle = {
  id: "getting-started-guide",
  title: "Getting started",
  kind: "hub",
  children: [
    {
      id: "signing-up",
      title: "Signing up",
      kind: "content",
      paragraphs: [
        "Download Fast Bull, enter your phone number, verify OTP, and complete your profile to start booking.",
      ],
    },
    {
      id: "getting-started",
      title: "Getting started",
      kind: "content",
      paragraphs: [
        "Set pickup and dropoff on Home, choose a service, select payment, and confirm your booking.",
      ],
    },
    {
      id: "how-wavego-works",
      title: "How Fast Bull works",
      kind: "content",
      paragraphs: [
        "Fast Bull connects you with nearby captains for rides, deliveries, and emergency ambulance services in real time.",
      ],
    },
    {
      id: "pickup-to-dropoff",
      title: "From pickup to dropoff",
      kind: "content",
      paragraphs: [
        "Track your captain live, share trip status, and pay automatically or with cash at the end of your trip.",
      ],
    },
  ],
};

export const guidesPoliciesHub: HelpArticle = {
  id: "policies-legal",
  title: "Policies and legal",
  kind: "hub",
  children: [
    {
      id: "policies",
      title: "Policies",
      kind: "content",
      paragraphs: [
        "Review our Terms of Service, Privacy Policy, and Safety Policy for full platform guidelines.",
      ],
    },
    {
      id: "data-privacy",
      title: "Data and privacy",
      kind: "content",
      paragraphs: ["Learn how we collect, use, and protect your personal information."],
      link: { label: "Open Privacy Policy", href: ROUTES.privacy },
    },
    {
      id: "pricing-fees",
      title: "Pricing and fees",
      kind: "content",
      paragraphs: [
        "Fares include base rate, distance, time, and applicable taxes. Surge pricing may apply during high demand.",
      ],
    },
  ],
};

export const guidesServicesHub: HelpArticle = {
  id: "wavego-services",
  title: "Fast Bull services",
  kind: "hub",
  children: [
    {
      id: "wavego-delivery",
      title: "Fast Bull for delivery",
      kind: "content",
      paragraphs: [
        "Send packages across the city with live tracking and proof of delivery.",
      ],
    },
    {
      id: "business-travel",
      title: "Fast Bull for business travel",
      kind: "content",
      paragraphs: [
        "Corporate accounts offer centralized billing, trip reports, and admin dashboards.",
      ],
    },
    {
      id: "intercity-faqs",
      title: "Fast Bull Intercity FAQs",
      kind: "content",
      paragraphs: [
        "Intercity trips connect cities with upfront pricing and scheduled pickups.",
      ],
    },
    {
      id: "wavego-pet",
      title: "Fast Bull Pet — a ride for all paws",
      kind: "content",
      paragraphs: [
        "Pet-friendly rides are available in select cities. Choose Pet option when booking and follow pet carrier guidelines.",
      ],
    },
    {
      id: "delegate-profiles",
      title: "Delegate profiles FAQ",
      kind: "content",
      paragraphs: [
        "Book rides for family members by adding delegate profiles in Account Settings.",
      ],
    },
  ],
};

export const guidesSupportHub: HelpArticle = {
  id: "support-about",
  title: "Support and about",
  kind: "hub",
  children: [
    {
      id: "india-support",
      title: "About India Customer support",
      kind: "content",
      paragraphs: ["Fast Bull support is available 24/7 for riders across India in English and Hindi."],
    },
    {
      id: "faq",
      title: "Frequently Asked Questions",
      kind: "content",
      paragraphs: [
        "Find answers to common questions about booking, payments, safety, and account management in Help & Support topics.",
      ],
    },
    {
      id: "careers",
      title: "Careers",
      kind: "content",
      paragraphs: [
        "Join the Fast Bull team. Visit careers.wavego.in for open roles in engineering, operations, and support.",
      ],
    },
  ],
};

export const membershipOverviewHub: HelpArticle = {
  id: "membership-overview",
  title: "Fast Bull Plus",
  kind: "hub",
  children: [
    {
      id: "wavego-plus",
      title: "Fast Bull Plus membership",
      kind: "content",
      paragraphs: [
        "Fast Bull Plus offers discounted rides, priority support, and exclusive promos for frequent riders.",
      ],
    },
    {
      id: "membership-benefits",
      title: "Membership benefits",
      kind: "content",
      paragraphs: [
        "Benefits include reduced service fees, member-only offers, and faster support response times.",
      ],
    },
    {
      id: "cancel-membership",
      title: "Cancel or change membership",
      kind: "content",
      paragraphs: [
        "Manage your membership from Profile → Account Settings. Cancellation takes effect at the end of the billing cycle.",
      ],
    },
  ],
};

export const accessibilityResourcesHub: HelpArticle = {
  id: "accessibility-resources",
  title: "Accessibility resources",
  kind: "hub",
  children: [
    {
      id: "riders-with-disabilities",
      title: "Resources for riders with disabilities",
      kind: "content",
      paragraphs: [
        "Fast Bull supports accessible vehicles where available. Enable accessibility preferences in Account Settings.",
        "Contact support to request wheelchair-accessible cabs or assistance at pickup.",
      ],
    },
    {
      id: "screen-readers",
      title: "Using TalkBack and VoiceOver",
      kind: "content",
      paragraphs: [
        "Fast Bull is compatible with TalkBack (Android) and VoiceOver (iOS).",
        "Enable your device's screen reader for labeled buttons, trip status announcements, and navigation support.",
      ],
    },
  ],
};

export const mapIssuesHub: HelpArticle = {
  id: "map-issues",
  title: "Report a map issue",
  kind: "hub",
  children: [
    {
      id: "report-map-problem",
      title: "Report a problem in the Fast Bull map",
      kind: "content",
      paragraphs: [
        "If pickup pins or routes appear wrong, report the issue with a screenshot and location details.",
      ],
    },
    {
      id: "business-landmark",
      title: "Fix a business or landmark issue on Fast Bull Maps",
      kind: "content",
      paragraphs: [
        "Submit corrections for missing or incorrect business names and landmarks.",
      ],
    },
    {
      id: "incorrect-address",
      title: "Fix an incorrect address on Fast Bull Maps",
      kind: "content",
      paragraphs: [
        "Help us improve by reporting addresses that don't match the actual location.",
      ],
    },
    {
      id: "road-info",
      title: "Fix road information on Fast Bull Maps",
      kind: "content",
      paragraphs: [
        "Report closed roads, one-way errors, or missing streets for our map team to review.",
      ],
    },
  ],
};

export const transitHub: HelpArticle = {
  id: "transit-options",
  title: "Transit options",
  kind: "hub",
  children: [
    {
      id: "delhi-metro",
      title: "Delhi Metro",
      kind: "content",
      paragraphs: [
        "Plan metro journeys with Fast Bull transit integration. View routes, fares, and nearby stations.",
      ],
    },
    {
      id: "trains",
      title: "Trains",
      kind: "content",
      paragraphs: [
        "Check train schedules and book connecting rides to and from railway stations.",
      ],
    },
    {
      id: "intercity-bus",
      title: "Intercity Bus",
      kind: "content",
      paragraphs: [
        "Find intercity bus routes and book last-mile rides to bus terminals with Fast Bull.",
      ],
    },
  ],
};

export const cancellationHub: HelpArticle = {
  id: "cancellation-help",
  title: "Cancellation help",
  kind: "hub",
  children: [
    {
      id: "cancelling-a-ride",
      title: "Cancelling a ride",
      kind: "content",
      paragraphs: [
        "Free cancellation is available within 2 minutes of booking or before a captain is assigned.",
        "After a captain is assigned, a cancellation fee may apply based on vehicle type and wait time.",
        "Ambulance bookings follow a separate emergency cancellation policy — contact support immediately.",
      ],
    },
  ],
};

export const passesHub: HelpArticle = {
  id: "ride-passes",
  title: "Ride Passes",
  kind: "hub",
  children: [
    {
      id: "commute-pass",
      title: "Commute Pass",
      kind: "content",
      paragraphs: [
        "Save on daily commutes with a Fast Bull Commute Pass — fixed rides at a discounted rate for 30 days.",
        "Purchase from Wallet → Ride Passes and apply automatically on eligible trips.",
      ],
    },
  ],
};

export const grievanceHub: HelpArticle = {
  id: "grievance-help",
  title: "Grievance redressal",
  kind: "hub",
  children: [
    {
      id: "grievance-redressal",
      title: "Grievance Redressal",
      kind: "content",
      paragraphs: [
        "Fast Bull is committed to resolving rider grievances fairly and promptly.",
        "Submit a grievance via Help & Support with your trip ID and details. Our team responds within 48 hours.",
        "For unresolved issues, escalate to our Grievance Officer at grievance@wavego.in.",
      ],
    },
  ],
};
