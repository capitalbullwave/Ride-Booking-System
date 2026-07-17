"use client";

import Link from "next/link";
import { notFound } from "next/navigation";
import { Headphones } from "lucide-react";
import { getHelpArticle, getHelpSection } from "@/data/help-center";
import { helpArticlePath, helpSectionPath } from "@/lib/help-routes";
import { ROUTES } from "@/constants/routes";
import {
  HelpArticleFeedback,
  HelpArticleLinkButton,
  HelpContentBlocks,
  HelpToggleList,
  HelpTripSelector,
} from "@/components/profile/help/HelpArticleParts";
import {
  HelpArticleRow,
  HelpTopicShell,
  articleIcon,
} from "@/components/profile/help/HelpTopicShell";
import { buttonVariants } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface HelpArticleViewProps {
  sectionId: string;
  articleId: string;
}

export function HelpArticleView({ sectionId, articleId }: HelpArticleViewProps) {
  const section = getHelpSection(sectionId);
  const article = getHelpArticle(sectionId, articleId);

  if (!section || !article) {
    notFound();
  }

  const breadcrumb = {
    sectionTitle: section.title,
    sectionId,
    parentTitle: article.parentTitle,
    parentId: article.parentId,
  };

  // Hub page — e.g. Fare review, Cash payment issues
  if (article.children && article.children.length > 0) {
    return (
      <HelpTopicShell title={article.title} breadcrumb={breadcrumb}>
        <div className="w-full">
          {article.children.map((child) => (
            <HelpArticleRow
              key={child.id}
              title={child.title}
              icon={articleIcon(child.title)}
              href={helpArticlePath(sectionId, child.id)}
            />
          ))}
        </div>
      </HelpTopicShell>
    );
  }

  const showFeedback = article.kind === "content" || !article.kind;

  return (
    <HelpTopicShell title={article.title} breadcrumb={breadcrumb} variant="light">
      <div className="max-w-3xl space-y-4">
        <HelpContentBlocks
          paragraphs={article.paragraphs}
          numberedList={article.numberedList}
        />

        {article.link && (
          <HelpArticleLinkButton link={article.link} sectionId={sectionId} />
        )}

        {article.kind === "trip-form" && <HelpTripSelector submitLabel="Next" />}

        {article.kind === "dispute-form" && article.toggles && (
          <>
            <HelpToggleList toggles={article.toggles} />
            <HelpTripSelector submitLabel="Submit" showDate />
          </>
        )}

        {article.kind === "report-form" && article.toggles && (
          <>
            <HelpToggleList toggles={article.toggles} />
            <HelpTripSelector submitLabel="Submit" />
          </>
        )}

        {showFeedback && <HelpArticleFeedback />}

        <div className="flex flex-wrap gap-3 pt-2">
          {article.parentId ? (
            <Link
              href={helpArticlePath(sectionId, article.parentId)}
              className={cn(buttonVariants({ variant: "outline" }), "rounded-[14px]")}
            >
              Back to {article.parentTitle}
            </Link>
          ) : (
            <Link
              href={helpSectionPath(sectionId)}
              className={cn(buttonVariants({ variant: "outline" }), "rounded-[14px]")}
            >
              Back to {section.title}
            </Link>
          )}
          <Link
            href={ROUTES.profileHelp}
            className={cn(buttonVariants(), "rounded-[14px]")}
          >
            <Headphones className="h-4 w-4" />
            Contact support
          </Link>
        </div>
      </div>
    </HelpTopicShell>
  );
}
