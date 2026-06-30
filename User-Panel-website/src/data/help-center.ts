import {
  accountPaymentsHub,
  accountProfileHub,
  accountSignInHub,
  accessibilityResourcesHub,
  cancellationHub,
  emergencyAssistanceHub,
  grievanceHub,
  guidesGettingStartedHub,
  guidesPoliciesHub,
  guidesServicesHub,
  guidesSupportHub,
  mapIssuesHub,
  membershipOverviewHub,
  passesHub,
  safetyPolicyHub,
  transitHub,
  tripSafetyHelpHub,
} from "./help-center-general";
import {
  accountHackedHub,
  cancellationsHub,
  cashPaymentHub,
  coRiderHub,
  deliveryIssuesHub,
  driverFeedbackHub,
  employeeTransportHub,
  fareReviewHub,
  lostItemHub,
  otherPaymentHub,
  tripSafetyHub,
} from "./help-center-trip-articles";

export type HelpArticleKind = "hub" | "content" | "trip-form" | "dispute-form" | "report-form";

export interface HelpArticleLink {
  label: string;
  articleId?: string;
  href?: string;
}

export interface HelpArticle {
  id: string;
  title: string;
  paragraphs?: string[];
  numberedList?: string[];
  link?: HelpArticleLink;
  externalRoute?: string;
  children?: HelpArticle[];
  kind?: HelpArticleKind;
  toggles?: string[];
  /** Set when resolving nested articles */
  parentId?: string;
  parentTitle?: string;
}

export interface HelpSection {
  id: string;
  title: string;
  articles: HelpArticle[];
}

export const helpSections: Record<string, HelpSection> = {
  trip: {
    id: "trip",
    title: "Help with a trip",
    articles: [
      cancellationsHub,
      fareReviewHub,
      cashPaymentHub,
      coRiderHub,
      otherPaymentHub,
      lostItemHub,
      deliveryIssuesHub,
      driverFeedbackHub,
      tripSafetyHub,
      employeeTransportHub,
      accountHackedHub,
    ],
  },
  account: {
    id: "account",
    title: "Account",
    articles: [accountSignInHub, accountProfileHub, accountPaymentsHub],
  },
  membership: {
    id: "membership",
    title: "Membership",
    articles: [membershipOverviewHub],
  },
  accessibility: {
    id: "accessibility",
    title: "Accessibility",
    articles: [accessibilityResourcesHub],
  },
  grievance: {
    id: "grievance",
    title: "Grievance redressal",
    articles: [grievanceHub],
  },
  guides: {
    id: "guides",
    title: "Guides",
    articles: [
      guidesGettingStartedHub,
      guidesPoliciesHub,
      guidesServicesHub,
      guidesSupportHub,
    ],
  },
  transit: {
    id: "transit",
    title: "Bus, Metro, and Train",
    articles: [transitHub],
  },
  cancellation: {
    id: "cancellation",
    title: "Cancellation policy",
    articles: [cancellationHub],
  },
  map: {
    id: "map",
    title: "Map issue",
    articles: [mapIssuesHub],
  },
  passes: {
    id: "passes",
    title: "Ride Passes",
    articles: [passesHub],
  },
  "safety-emergency": {
    id: "safety-emergency",
    title: "Safety & emergency",
    articles: [safetyPolicyHub, emergencyAssistanceHub, tripSafetyHelpHub],
  },
};

export function getHelpSection(sectionId: string): HelpSection | undefined {
  return helpSections[sectionId];
}

export function getHelpArticle(sectionId: string, articleId: string): HelpArticle | undefined {
  const section = helpSections[sectionId];
  if (!section) return undefined;

  for (const article of section.articles) {
    if (article.id === articleId) return article;
    if (article.children) {
      const child = article.children.find((c) => c.id === articleId);
      if (child) {
        return {
          ...child,
          parentId: article.id,
          parentTitle: article.title,
        };
      }
    }
  }
  return undefined;
}

export function getHelpHubArticles(sectionId: string, articleId: string): HelpArticle[] | undefined {
  const article = getHelpArticle(sectionId, articleId);
  if (article?.children?.length) return article.children;
  return undefined;
}

export const helpSectionList = Object.values(helpSections);
