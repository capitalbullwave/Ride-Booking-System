import { HelpArticleView } from "@/components/profile/help";

interface HelpArticlePageProps {
  params: Promise<{ section: string; article: string }>;
}

export default async function HelpArticlePage({ params }: HelpArticlePageProps) {
  const { section, article } = await params;
  return <HelpArticleView sectionId={section} articleId={article} />;
}
