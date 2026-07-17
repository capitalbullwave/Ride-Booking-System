"use client";

import { notFound } from "next/navigation";
import { getHelpSection } from "@/data/help-center";
import { helpArticlePath } from "@/lib/help-routes";
import {
  HelpArticleRow,
  HelpTopicShell,
  articleIcon,
} from "@/components/profile/help/HelpTopicShell";

interface HelpSectionViewProps {
  sectionId: string;
}

export function HelpSectionView({ sectionId }: HelpSectionViewProps) {
  const section = getHelpSection(sectionId);

  if (!section) {
    notFound();
  }

  return (
    <HelpTopicShell title={section.title}>
      <div className="w-full">
        {section.articles.map((article) => (
          <HelpArticleRow
            key={article.id}
            title={article.title}
            icon={articleIcon(article.title)}
            href={helpArticlePath(sectionId, article.id)}
          />
        ))}
      </div>
    </HelpTopicShell>
  );
}
