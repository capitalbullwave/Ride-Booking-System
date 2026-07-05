class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceLabel,
    required this.periodLabel,
    required this.description,
    required this.benefits,
    this.isPopular = false,
  });

  final String id;
  final String name;
  final String priceLabel;
  final String periodLabel;
  final String description;
  final List<String> benefits;
  final bool isPopular;
}

const subscriptionPlans = <SubscriptionPlan>[
  SubscriptionPlan(
    id: 'free',
    name: 'Free',
    priceLabel: '₹0',
    periodLabel: 'forever',
    description: 'Essential rides at standard rates',
    benefits: [
      'Book rides anytime',
      'Standard pricing',
      'In-app support',
    ],
  ),
  SubscriptionPlan(
    id: 'plus',
    name: 'Plus',
    priceLabel: '₹99',
    periodLabel: '/month',
    description: 'Save more on every trip',
    benefits: [
      '5% off on every ride',
      'Priority booking',
      'No peak-hour surge up to 10%',
      '24/7 chat support',
    ],
    isPopular: true,
  ),
  SubscriptionPlan(
    id: 'premium',
    name: 'Premium',
    priceLabel: '₹199',
    periodLabel: '/month',
    description: 'Best value for frequent riders',
    benefits: [
      '10% off on every ride',
      'Zero surge pricing',
      'Priority driver matching',
      'Free cancellations (2/month)',
      'Dedicated support line',
    ],
  ),
];

SubscriptionPlan subscriptionPlanById(String id) {
  return subscriptionPlans.firstWhere(
    (plan) => plan.id == id,
    orElse: () => subscriptionPlans.first,
  );
}
