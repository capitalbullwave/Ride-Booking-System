import { HelpSectionView } from "@/components/profile/help";

interface HelpSectionPageProps {
  params: Promise<{ section: string }>;
}

export default async function HelpSectionPage({ params }: HelpSectionPageProps) {
  const { section } = await params;
  return <HelpSectionView sectionId={section} />;
}
