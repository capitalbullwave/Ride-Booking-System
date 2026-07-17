import { landingCaptainImage, landingHeroSlides } from "@/constants/services";

export type BlogCategory =
  | "Company"
  | "Safety"
  | "Captains"
  | "Product"
  | "Community";

export interface BlogPost {
  slug: string;
  title: string;
  excerpt: string;
  category: BlogCategory;
  date: string;
  readTime: string;
  image: string;
  imageAlt: string;
  author: string;
  paragraphs: string[];
}

export const blogPosts: BlogPost[] = [
  {
    slug: "wavego-ambulance-sos-launch",
    title: "Bull Wave rides Ambulance SOS: Emergency care, one tap away",
    excerpt:
      "We launched integrated ambulance booking so riders can request verified medical transport without leaving the Bull Wave rides app.",
    category: "Product",
    date: "2026-05-12",
    readTime: "4 min read",
    image: landingHeroSlides[4].src,
    imageAlt: "Bull Wave rides ambulance service",
    author: "Bull Wave rides Team",
    paragraphs: [
      "Every second counts in a medical emergency. That is why Bull Wave rides Ambulance SOS is built directly into the same app you use for rides and parcels — no separate downloads, no confusing flows.",
      "When you request an ambulance, Bull Wave rides matches you with verified medical transport partners, shows live ETA, and shares trip details with your emergency contacts automatically.",
      "Our captains undergo additional training for medical transport routes, hospital coordination, and calm customer communication under pressure.",
      "Ambulance SOS is rolling out across major metros first, with expansion planned for tier-2 cities through 2026. Tap Emergency on the home screen or landing page to get started.",
    ],
  },
  {
    slug: "50-cities-and-counting",
    title: "50 cities and counting: Bull Wave rides's expansion across India",
    excerpt:
      "From a single-city pilot to a nationwide mobility network — how Bull Wave rides is bringing reliable rides to more communities every month.",
    category: "Company",
    date: "2026-04-28",
    readTime: "5 min read",
    image: landingHeroSlides[3].src,
    imageAlt: "Bull Wave rides fleet on Indian roads",
    author: "Priya Sharma",
    paragraphs: [
      "Bull Wave rides started with a simple belief: Indian cities deserve mobility that is fast, fair, and safe. Today we operate in over 50 cities, connecting millions of rides, parcels, and emergency trips each quarter.",
      "Expansion is not just about maps on a website. Each new city gets local captain onboarding, regional pricing, airport and hospital route coverage, and a dedicated support team that understands local roads and peak-hour patterns.",
      "We prioritise neighbourhoods that are underserved by traditional transport — late-night corridors, hospital zones, and industrial hubs where reliable pickup matters most.",
      "Thank you to our riders, captains, and city partners who make every new launch possible. The wave is only getting bigger.",
    ],
  },
  {
    slug: "captain-earnings-transparency",
    title: "Transparent earnings: What Bull Wave rides captains actually take home",
    excerpt:
      "No hidden cuts, no surprise deductions — a clear look at how captain payouts work on Bull Wave rides.",
    category: "Captains",
    date: "2026-04-10",
    readTime: "6 min read",
    image: landingCaptainImage,
    imageAlt: "Bull Wave rides captain partner",
    author: "Rahul Kapoor",
    paragraphs: [
      "Captains are the backbone of Bull Wave rides. We heard loud and clear that unclear earnings were the number-one frustration on other platforms — so we rebuilt payouts from the ground up.",
      "Before you accept a trip, you see an estimated earning breakdown: base fare, distance component, time component, and any active incentives. What you see before the ride is what lands in your wallet after completion.",
      "Weekly settlements hit your bank account with zero platform fees hidden in fine print. Bonuses for peak hours, referral rewards, and safety milestones are listed separately so nothing feels like a mystery.",
      "If you are considering driving with Bull Wave rides, visit the Captains section on our homepage or sign in to explore partner onboarding in your city.",
    ],
  },
  {
    slug: "monsoon-ride-safety-tips",
    title: "7 monsoon ride safety tips every Bull Wave rides rider should know",
    excerpt:
      "Heavy rain changes how we move through the city. Here is how to stay safe, dry, and informed during the monsoon season.",
    category: "Safety",
    date: "2026-03-22",
    readTime: "3 min read",
    image: landingHeroSlides[0].src,
    imageAlt: "Safe Bull Wave rides ride in the city",
    author: "Bull Wave rides Safety Team",
    paragraphs: [
      "Monsoon season brings flooded roads, reduced visibility, and longer trip times. Bull Wave rides adjusts ETAs for weather, but a few habits from you make every ride safer.",
      "Share your live trip with a family member before you leave, especially on late-night or long-distance rides. Use in-app SOS if you ever feel unsafe — our team is available 24×7.",
      "Wait under cover for your captain when possible. Confirm the vehicle number and captain name in the app before boarding.",
      "For ambulance or urgent medical trips during floods, use Ambulance SOS and keep your pickup pin as precise as possible so responders reach you faster.",
      "Read our full Safety page for captain verification, insurance coverage, and community guidelines that protect everyone on the platform.",
    ],
  },
  {
    slug: "parcel-delivery-milestone",
    title: "One million parcels delivered: Bull Wave rides Parcel hits a milestone",
    excerpt:
      "Same-day intra-city delivery is now a core part of how businesses and families move goods across Bull Wave rides cities.",
    category: "Product",
    date: "2026-03-05",
    readTime: "4 min read",
    image: landingHeroSlides[2].src,
    imageAlt: "Bull Wave rides parcel delivery",
    author: "Bull Wave rides Team",
    paragraphs: [
      "Bull Wave rides Parcel crossed one million completed deliveries this quarter — documents, gifts, pharmacy runs, and small business shipments that needed to move fast within the city.",
      "Parcel rides use the same verified captain network as passenger trips, with photo proof at pickup and drop-off, live tracking for senders, and insured coverage on eligible items.",
      "Businesses can book recurring routes from the app, and families use Parcel for everything from forgotten laptops to surprise birthday cakes across town.",
      "Try Parcel from the landing page booking widget or the home screen — enter pickup and delivery addresses, see upfront pricing, and send in minutes.",
    ],
  },
  {
    slug: "women-safety-commitment",
    title: "Our commitment to women riders and captains",
    excerpt:
      "Dedicated safety features, training, and support channels designed for women on both sides of every Bull Wave rides trip.",
    category: "Community",
    date: "2026-02-14",
    readTime: "5 min read",
    image: landingHeroSlides[1].src,
    imageAlt: "Bull Wave rides community safety",
    author: "Bull Wave rides Safety Team",
    paragraphs: [
      "Women make up a growing share of Bull Wave rides riders and captains. Their safety is not an add-on feature — it is central to how we design products, policies, and support.",
      "Riders can share trips in one tap, access masked calling, and reach a 24×7 safety team trained on gender-sensitive incident response. Captains receive dedicated helplines and route assistance when they report concerns on the road.",
      "We partner with local NGOs and women's safety groups in each launch city to refine training and community reporting channels.",
      "Have feedback or ideas? Reach us through Help & Support in the app — every report is reviewed by our trust and safety team within 24 hours.",
    ],
  },
];

export function getBlogPost(slug: string): BlogPost | undefined {
  return blogPosts.find((post) => post.slug === slug);
}

export function getBlogPostsByCategory(category: BlogCategory): BlogPost[] {
  return blogPosts.filter((post) => post.category === category);
}

export const blogCategories: BlogCategory[] = [
  "Company",
  "Product",
  "Safety",
  "Captains",
  "Community",
];
