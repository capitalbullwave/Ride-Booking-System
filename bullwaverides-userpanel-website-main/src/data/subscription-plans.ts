export interface SubscriptionPlan {
  id: string;
  name: string;
  priceLabel: string;
  periodLabel: string;
  description: string;
  benefits: string[];
  isPopular?: boolean;
}

export const SUBSCRIPTION_PLANS: SubscriptionPlan[] = [
  {
    id: "free",
    name: "Free",
    priceLabel: "₹0",
    periodLabel: "forever",
    description: "Essential rides at standard rates",
    benefits: ["Book rides anytime", "Standard pricing", "In-app support"],
  },
  {
    id: "plus",
    name: "Plus",
    priceLabel: "₹99",
    periodLabel: "/month",
    description: "Save more on every trip",
    benefits: [
      "5% off on every ride",
      "Priority booking",
      "No peak-hour surge up to 10%",
      "24/7 chat support",
    ],
    isPopular: true,
  },
  {
    id: "premium",
    name: "Premium",
    priceLabel: "₹199",
    periodLabel: "/month",
    description: "Best value for frequent riders",
    benefits: [
      "10% off on every ride",
      "Zero surge pricing",
      "Priority driver matching",
      "Free cancellations (2/month)",
      "Dedicated support line",
    ],
  },
];

export function getSubscriptionPlan(id: string): SubscriptionPlan {
  return SUBSCRIPTION_PLANS.find((plan) => plan.id === id) ?? SUBSCRIPTION_PLANS[0];
}
