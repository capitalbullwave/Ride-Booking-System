import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { BlogArticleView } from "@/components/landing/BlogArticleView";
import { getBlogPost, blogPosts } from "@/data/blogs";

interface BlogArticlePageProps {
  params: Promise<{ slug: string }>;
}

export function generateStaticParams() {
  return blogPosts.map((post) => ({ slug: post.slug }));
}

export async function generateMetadata({
  params,
}: BlogArticlePageProps): Promise<Metadata> {
  const { slug } = await params;
  const post = getBlogPost(slug);

  if (!post) {
    return { title: "Blog | Bull Wave rides" };
  }

  return {
    title: `${post.title} | Bull Wave rides Blog`,
    description: post.excerpt,
  };
}

export default async function BlogArticlePage({ params }: BlogArticlePageProps) {
  const { slug } = await params;

  if (!getBlogPost(slug)) {
    notFound();
  }

  return <BlogArticleView slug={slug} />;
}
