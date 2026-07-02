"use client";

import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowLeft, Clock } from "lucide-react";
import { LandingHeader } from "@/components/landing/LandingHeader";
import { AnimateIn } from "@/components/motion";
import { getBlogPost } from "@/data/blogs";
import { ROUTES } from "@/constants/routes";
import { cn } from "@/lib/utils";

const categoryStyles = {
  Company: "bg-primary/10 text-primary",
  Product: "bg-secondary/40 text-foreground",
  Safety: "bg-success/15 text-success",
  Captains: "bg-muted text-foreground",
  Community: "bg-destructive/10 text-destructive",
} as const;

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}

interface BlogArticleViewProps {
  slug: string;
}

export function BlogArticleView({ slug }: BlogArticleViewProps) {
  const post = getBlogPost(slug);

  if (!post) {
    notFound();
  }

  return (
    <div className="min-h-screen bg-background font-sans">
      <LandingHeader />

      <article className="px-6 py-10 md:py-14">
        <AnimateIn className="mx-auto max-w-3xl">
          <Link
            href={ROUTES.blogs}
            className="mb-8 inline-flex items-center gap-2 text-sm font-semibold text-primary hover:underline"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to all blogs
          </Link>

          <span
            className={cn(
              "inline-block rounded-full px-3 py-1 text-xs font-bold uppercase tracking-wide",
              categoryStyles[post.category]
            )}
          >
            {post.category}
          </span>

          <h1 className="mt-4 font-heading text-3xl font-bold leading-tight text-foreground sm:text-4xl lg:text-[2.75rem]">
            {post.title}
          </h1>

          <div className="mt-5 flex flex-wrap items-center gap-x-4 gap-y-1 text-sm text-muted-foreground">
            <span>{post.author}</span>
            <span aria-hidden>·</span>
            <span>{formatDate(post.date)}</span>
            <span aria-hidden>·</span>
            <span className="flex items-center gap-1">
              <Clock className="h-4 w-4" />
              {post.readTime}
            </span>
          </div>

          <div className="relative mt-8 aspect-[16/9] overflow-hidden rounded-[20px] border border-border bg-muted/20 shadow-sm">
            <Image
              src={post.image}
              alt={post.imageAlt}
              fill
              className="object-cover"
              sizes="(max-width: 768px) 100vw, 768px"
              priority
            />
          </div>

          <div className="mt-10 space-y-5 text-base leading-relaxed text-foreground/90 sm:text-lg">
            {post.paragraphs.map((paragraph) => (
              <p key={paragraph.slice(0, 40)}>{paragraph}</p>
            ))}
          </div>
        </AnimateIn>
      </article>
    </div>
  );
}
