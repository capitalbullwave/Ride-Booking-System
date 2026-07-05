import { ROUTES } from "@/constants/routes";
import type { HelpArticle } from "./help-center";

export const fareReviewArticles: HelpArticle[] = [
  {
    id: "review-upfront-price",
    title: "Review change in upfront trip price",
    kind: "trip-form",
    paragraphs: [
      "Before confirming your trip, you'll see either an upfront price or an estimated range (can vary by location).",
      "If you feel your trip price was too high, please let us know within 30 days of the trip.",
      "Select the trip you want us to review, and then select Next.",
    ],
  },
  {
    id: "dispute-wait-time-fee",
    title: "Dispute my wait time fee",
    kind: "dispute-form",
    paragraphs: [
      "Per-minute wait fees start a few minutes after a captain arrives and continue until the trip begins.",
      "If a trip is cancelled and a cancellation fee is charged, no wait time fee applies.",
      "Use the toggles below if you feel you were unfairly charged.",
    ],
    toggles: [
      "I was not ready",
      "My Fast Bull arrived too quickly",
      "My captain made me walk to the location",
      "I could not connect or find my captain",
      "My captain made me wait",
    ],
  },
  {
    id: "intercity-tolls-cash",
    title: "Captain asked to pay cash for tolls on intercity trip",
    kind: "content",
    paragraphs: ["When you request an Intercity Trip on Fast Bull, please note:"],
    numberedList: [
      "Toll and State taxes are to be paid by you over and above the fare shown on the app when you requested the trip.",
      "Some vehicles might have FASTag enabled. The toll for such vehicles will be paid automatically through the captain's account. It should still be paid by the rider in cash to the captain.",
      "FASTag is an electronic toll collection system in India, operated by the National Highway Authority of India.",
    ],
  },
  {
    id: "changed-destination",
    title: "I changed my destination",
    kind: "content",
    paragraphs: [
      "When you request a ride, you are shown an upfront fare, which is our estimate for how much the trip should cost, based on the estimated distance, time and tolls, and it holds as long as destination remains unchanged and the GPS suggested route is followed.",
      "Please note that if you get dropped off at a destination other than what you requested, or if you entered a destination that was not marked correctly on the map, your fare will change to a fare based on the actual distance, time and tolls for the trip.",
      "We recommend that you enter the exact destination in the app to prevent confusion on the amount you need to pay.",
    ],
  },
  {
    id: "rental-package-not-used",
    title: "I did not use my whole package but was charged the whole amount",
    kind: "content",
    paragraphs: [
      "Rental trips allow you to rent a Fast Bull for multiple hours, according to the package chosen by you. The pricing for an Hourly Rental trip depends on the package that you choose.",
      "Please note that if the time or distance covered during the trip is less than the specifications of the selected package, you will be charged for the entire package fare, as selected by you.",
      "If you still feel that you were charged a higher fare for this trip, please do let us know by selecting the link below:",
    ],
    link: { label: "My fare for the Rental trip was higher than expected", articleId: "rental-fare-higher" },
  },
  {
    id: "rental-charged-more",
    title: "I was charged more than my Rental package",
    kind: "content",
    paragraphs: [
      "Rental trips allow you to rent a Fast Bull for multiple hours, according to the package chosen by you.",
      "When you request a Rental Trip on Fast Bull, please note:",
    ],
    numberedList: [
      "Tolls are included in the package fare shown for the trip and should be paid over and above the final fare.",
      "Parking fee will not be included in the final fare. You will have to pay the parking fee directly to the captain.",
      "The pricing for a Rental trip depends on the package that you choose. However, if the time or distance crosses the limitation of the package, you will be charged more than your package fare.",
    ],
    link: { label: "My fare for the Rental trip was higher than expected", articleId: "rental-fare-higher" },
  },
  {
    id: "rental-fare-higher",
    title: "My fare for the Rental trip was higher than expected",
    kind: "content",
    paragraphs: [
      "The pricing for a Rental trip depends on the package that you choose. However, if the time or distance crosses the limitation of the package, you will be charged more than your package fare, according to the additional time and distance travelled.",
      "Toll fares are added at the end of the trip and are not included in the package fare.",
      "Parking fees are not included in the final fare and must be paid directly to the captain.",
      "If you still feel that you were overcharged for this trip, we will be happy to review this for you. Please contact us via Help & Support.",
    ],
  },
  {
    id: "driver-didnt-end-trip",
    title: "My captain didn't end the trip at the destination",
    kind: "report-form",
    paragraphs: [
      "This form is for reporting cases when your captain didn't complete the trip at the intended drop-off point entered by you in the Fast Bull app.",
      "This may happen if the captain continues driving after drop-off, or stays at the location without ending the trip.",
      "If you feel that the fare was higher than expected due to any of these reasons, please let us know by filling the form below:",
    ],
    toggles: ["My captain didn't end the trip at my drop off location"],
  },
  {
    id: "driver-ended-rental-early",
    title: "My captain ended my Rental trip before it was complete",
    kind: "content",
    paragraphs: [
      "Rental trips allow you to rent a Fast Bull for multiple hours, according to the package chosen by you.",
      "If your captain ended the trip before the package time or distance was complete, please contact us via Help & Support with your trip details.",
    ],
  },
  {
    id: "intercity-fare-higher",
    title: "The fare for my Intercity trip is higher than expected",
    kind: "content",
    paragraphs: [
      "Upfront fares for Intercity trips are calculated based on expected time, distance, and traffic. The final amount may differ if the route deviates from the predicted one.",
      "Tolls and state taxes are not included in the upfront fare and must be paid by you over and above the final fare.",
      "Parking fees are also not included and should be paid directly to the captain.",
      "If you still feel that you were overcharged for this trip, we will be happy to review this for you. Please contact us via Help & Support.",
    ],
    link: { label: "Concerns on being charged toll on your Intercity trip", articleId: "intercity-tolls-cash" },
  },
];

export const cashPaymentArticles: HelpArticle[] = [
  {
    id: "paid-extra-cash-direct",
    title: "I paid extra cash (or) cash directly to the captain",
    kind: "content",
    paragraphs: [
      "If you paid more cash than shown in the app, report the trip from Bookings with the amount paid and trip ID.",
      "Our team will verify with the captain and process a refund if applicable.",
    ],
  },
  {
    id: "someone-else-took-trip",
    title: "Someone else took this trip",
    kind: "content",
    paragraphs: [
      "If you did not take a trip shown on your account, report it immediately via Help & Support.",
      "We will investigate and reverse any unauthorized charges.",
    ],
  },
  {
    id: "fare-higher-than-estimate",
    title: "My final fare was higher than the initial estimate",
    kind: "content",
    paragraphs: [
      "Fares may change if your route, destination, or wait time differs from the original estimate.",
      "Request a fare review within 30 days from Bookings or under Fare review topics.",
    ],
    link: { label: "Review change in upfront trip price", articleId: "review-upfront-price" },
  },
  {
    id: "paid-cash-digital-trip",
    title: "Paid cash on a digital trip",
    kind: "content",
    paragraphs: [
      "Digital payment trips should not require cash. If your captain asked for cash on a UPI or card trip, report the issue with trip details.",
    ],
  },
  {
    id: "how-fare-calculated",
    title: "How was my fare calculated?",
    kind: "content",
    paragraphs: [
      "Your fare includes base fare, distance, time, tolls, and applicable taxes. Surge pricing may apply during high demand.",
      "View the fare breakdown on your trip receipt in Bookings after completion.",
    ],
  },
  {
    id: "paid-extra-cash",
    title: "I paid extra cash",
    kind: "content",
    paragraphs: [
      "Select the trip in Bookings and report the extra amount paid. Refunds are processed after verification within 5–7 business days.",
    ],
  },
  {
    id: "driver-extra-cash-rentals",
    title: "Captain asked for extra cash on a Rentals trip",
    kind: "content",
    paragraphs: [
      "Rental package fares are shown upfront. Extra charges should only apply for tolls, parking, or package overages as explained in your receipt.",
      "Report unauthorized extra cash requests via Help & Support.",
    ],
  },
  {
    id: "report-fraud-cash-screen",
    title: "Report fraud cash screen shown",
    kind: "content",
    paragraphs: [
      "If you see an unexpected cash payment screen on a digital trip, do not pay and report the trip immediately.",
      "Our trust & safety team investigates all fraud reports.",
    ],
  },
  {
    id: "driver-extra-cash-intercity",
    title: "Captain asked for extra cash on an Intercity trip",
    kind: "content",
    paragraphs: [
      "Intercity trips may require toll and state tax payments in cash as noted at booking.",
      "Report any amount beyond tolls and taxes shown in the app via Help & Support.",
    ],
    link: { label: "Captain asked to pay cash for tolls on intercity trip", articleId: "intercity-tolls-cash" },
  },
];

export const fareReviewHub: HelpArticle = {
  id: "fare-review",
  title: "Fare review",
  kind: "hub",
  children: fareReviewArticles,
};

export const cashPaymentHub: HelpArticle = {
  id: "cash-payment-issues",
  title: "Cash payment issues",
  kind: "hub",
  children: cashPaymentArticles,
};

export const cancellationsHub: HelpArticle = {
  id: "cancellations",
  title: "Cancellations",
  kind: "hub",
  children: [
    {
      id: "cancelling-a-ride",
      title: "Cancelling a ride",
      kind: "content",
      paragraphs: [
        "Free cancellation is available within 2 minutes of booking or before a captain is assigned.",
        "After a captain is assigned, a cancellation fee may apply based on vehicle type and wait time.",
        "If your captain cancelled, you won't be charged. Check Bookings for refund status.",
      ],
    },
    {
      id: "cancellation-fee-dispute",
      title: "Dispute a cancellation fee",
      kind: "trip-form",
      paragraphs: [
        "If you were charged a cancellation fee unfairly, select the trip below and we'll review it.",
      ],
    },
  ],
};

export const lostItemHub: HelpArticle = {
  id: "lost-item",
  title: "Lost item",
  kind: "hub",
  children: [
    {
      id: "report-lost-item",
      title: "I lost an item in my ride",
      kind: "trip-form",
      paragraphs: [
        "Select the trip during which you lost your item. We'll help connect you with your captain.",
        "Fast Bull cannot guarantee item recovery but will assist with contact details.",
      ],
    },
    {
      id: "lost-item-tips",
      title: "Tips for finding a lost item",
      kind: "content",
      paragraphs: [
        "Report within 24 hours for the best chance of recovery.",
        "Provide a detailed description of the item and where you think it was left.",
        "Check Bookings for captain contact options after reporting.",
      ],
    },
  ],
};

export const deliveryIssuesHub: HelpArticle = {
  id: "delivery-issues",
  title: "Delivery issues",
  kind: "hub",
  children: [
    {
      id: "late-delivery",
      title: "My delivery was late",
      kind: "content",
      paragraphs: [
        "Deliveries may be delayed due to traffic or weather. Check live tracking for updated ETA.",
        "If your delivery was significantly late, report it within 24 hours for a review.",
      ],
    },
    {
      id: "damaged-delivery",
      title: "My package was damaged",
      kind: "trip-form",
      paragraphs: [
        "Report damaged deliveries within 24 hours with photos of the package and contents.",
        "Select the delivery trip below to start your report.",
      ],
    },
    {
      id: "missing-delivery",
      title: "Items missing from my delivery",
      kind: "trip-form",
      paragraphs: [
        "If items are missing from your delivery, select the trip and describe what was missing.",
      ],
    },
  ],
};

export const coRiderHub: HelpArticle = {
  id: "co-rider-issue",
  title: "I had an issue with a co-rider",
  kind: "hub",
  children: [
    {
      id: "co-rider-behaviour",
      title: "Report co-rider behaviour",
      kind: "content",
      paragraphs: [
        "Fast Bull Pool trips may include other riders along your route.",
        "Report inappropriate behaviour immediately. Our team reviews all co-rider reports within 48 hours.",
      ],
    },
    {
      id: "co-rider-safety",
      title: "Safety concerns with a co-rider",
      kind: "content",
      paragraphs: [
        "For immediate safety concerns during a trip, use in-app emergency options or call 112.",
        "After the trip, file a detailed report via Help & Support with your trip ID.",
      ],
      link: { label: "View Safety Policy", href: ROUTES.safety },
    },
  ],
};

export const driverFeedbackHub: HelpArticle = {
  id: "driver-feedback",
  title: "Feedback about the captain or vehicle",
  kind: "hub",
  children: [
    {
      id: "rate-captain",
      title: "Rate your captain",
      kind: "content",
      paragraphs: [
        "After each trip, rate your captain from 1–5 stars and leave optional feedback.",
        "Ratings help us maintain quality and recognize top captains.",
      ],
    },
    {
      id: "vehicle-issue",
      title: "Issue with the vehicle",
      kind: "trip-form",
      paragraphs: [
        "Report cleanliness, safety, or vehicle condition issues by selecting your trip below.",
      ],
    },
    {
      id: "captain-safety-report",
      title: "Report a safety concern",
      kind: "content",
      paragraphs: [
        "For serious safety concerns, contact support immediately with trip details.",
        "We may suspend captains pending investigation of safety reports.",
      ],
    },
  ],
};

export const otherPaymentHub: HelpArticle = {
  id: "other-payment-support",
  title: "Other payment support",
  kind: "hub",
  children: [
    {
      id: "wallet-issues",
      title: "Fast Bull Wallet issues",
      kind: "content",
      paragraphs: [
        "Check Wallet for transaction history and pending balances.",
        "Wallet top-ups usually reflect within a few minutes.",
      ],
      link: { label: "Open Wallet", href: ROUTES.wallet },
    },
    {
      id: "upi-card-issues",
      title: "UPI or card payment failed",
      kind: "content",
      paragraphs: [
        "Failed payments are usually reversed within 5–7 business days by your bank.",
        "Try an alternate payment method or Fast Bull Cash to complete your booking.",
      ],
    },
    {
      id: "refund-status",
      title: "Check refund status",
      kind: "content",
      paragraphs: [
        "Refunds for cancelled trips appear in Bookings under the trip receipt.",
        "Bank refunds may take 5–10 business days depending on your payment provider.",
      ],
    },
  ],
};

export const accountHackedHub: HelpArticle = {
  id: "account-hacked",
  title: "I think my account was hacked",
  kind: "hub",
  children: [
    {
      id: "secure-account",
      title: "Secure your account",
      kind: "content",
      paragraphs: [
        "Sign out of all devices from Account Settings and update your phone number if compromised.",
        "Review recent trips in Bookings for any activity you don't recognize.",
      ],
      link: { label: "Account Settings", href: ROUTES.profileAccountSettings },
    },
    {
      id: "report-unauthorized-trips",
      title: "Report unauthorized trips",
      kind: "trip-form",
      paragraphs: [
        "Select any trips you did not take below. We'll investigate and reverse unauthorized charges.",
      ],
    },
  ],
};

export const employeeTransportHub: HelpArticle = {
  id: "employee-transport",
  title: "Employee Transport Support",
  kind: "hub",
  children: [
    {
      id: "corporate-programs",
      title: "Corporate commute programs",
      kind: "content",
      paragraphs: [
        "Fast Bull for Business offers centralized billing, route management, and employee dashboards.",
        "Contact business@wavego.in to set up a corporate account.",
      ],
    },
    {
      id: "employee-trip-issues",
      title: "Issues with a corporate trip",
      kind: "trip-form",
      paragraphs: [
        "Select the corporate trip below to report billing or scheduling issues.",
      ],
    },
  ],
};

export const tripSafetyHub: HelpArticle = {
  id: "trip-safety",
  title: "Safety",
  kind: "hub",
  children: [
    {
      id: "safety-policy-link",
      title: "Fast Bull Safety Policy",
      kind: "content",
      paragraphs: ["Read how we keep every trip and emergency request safe."],
      link: { label: "Open Safety Policy", href: ROUTES.safety },
    },
    {
      id: "emergency-during-trip",
      title: "Emergency during a trip",
      kind: "content",
      paragraphs: [
        "Use in-app SOS and live tracking during active rides.",
        "For medical emergencies, call 112 in addition to using Fast Bull ambulance services.",
      ],
      link: { label: "Request ambulance", href: ROUTES.ambulance },
    },
    {
      id: "share-trip-status",
      title: "Share trip with contacts",
      kind: "content",
      paragraphs: [
        "Share live location with family or friends from the tracking screen during any active trip.",
      ],
    },
  ],
};
