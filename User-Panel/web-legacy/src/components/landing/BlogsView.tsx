"use client";

import Image from "next/image";
import Link from "next/link";
import { useMemo, useState } from "react";
import { ArrowRight, Clock } from "lucide-react";
import { LandingHeader } from "@/components/landing/LandingHeader";
import { AnimateIn, Stagger, StaggerItem } from "@/components/motion";
import { blogCategories, blogPosts, type BlogCategory } from "@/data/blogs";
import { blogPostPath } from "@/lib/blog-routes";
import { cn } from "@/lib/utils";

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

const categoryStyles: Record<BlogCategory, string> = {
  Company: "bg-primary/10 text-primary",
  Product: "bg-secondary/40 text-foreground",
  Safety: "bg-success/15 text-success",
  Captains: "bg-muted text-foreground",
  Community: "bg-destructive/10 text-destructive",
};

export function BlogsView() {
  const [activeCategory, setActiveCategory] = useState<BlogCategory | "All">("All");

  const filteredPosts = useMemo(() => {
    if (activeCategory === "All") return blogPosts;
    return blogPosts.filter((post) => post.category === activeCategory);
  }, [activeCategory]);

  return (
    <div className="min-h-screen bg-background font-sans">
      <LandingHeader />

      <section className="border-b border-border bg-card px-6 py-14 md:py-20">
        <AnimateIn className="mx-auto max-w-6xl">
          <p className="text-xs font-bold uppercase tracking-widest text-primary">
            Bull Wave Rides Blog
          </p>
          <h1 className="mt-3 font-heading text-4xl font-bold text-foreground sm:text-5xl">
            Stories, updates &amp; insights
          </h1>
          <p className="mt-4 max-w-2xl text-base leading-relaxed text-muted-foreground sm:text-lg">
            Company news, product launches, safety guides, and captain stories from
            the team building India&apos;s trusted mobility platform.
          </p>
        </AnimateIn>
      </section>

      <section className="px-6 py-10">
        <div className="mx-auto max-w-6xl">
          <div className="flex flex-wrap gap-2">
            <button
              type="button"
              onClick={() => setActiveCategory("All")}
              className={cn(
                "rounded-full px-4 py-2 text-sm font-semibold transition-colors",
                activeCategory === "All"
                  ? "bg-primary text-white"
                  : "bg-muted/60 text-muted-foreground hover:bg-muted hover:text-foreground"
              )}
            >
              All
            </button>
            {blogCategories.map((category) => (
              <button
                key={category}
                type="button"
                onClick={() => setActiveCategory(category)}
                className={cn(
                  "rounded-full px-4 py-2 text-sm font-semibold transition-colors",
                  activeCategory === category
                    ? "bg-primary text-white"
                    : "bg-muted/60 text-muted-foreground hover:bg-muted hover:text-foreground"
                )}
              >
                {category}
              </button>
            ))}
          </div>

          <Stagger className="mt-10 grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
            {filteredPosts.map((post, index) => (
              <StaggerItem key={post.slug} index={index}>
                <Link
                  href={blogPostPath(post.slug)}
                  className="group flex h-full flex-col overflow-hidden rounded-[20px] border border-border bg-card shadow-sm transition-shadow hover:shadow-md"
                >
                  <div className="relative aspect-[16/10] overflow-hidden bg-muted/30">
                    <Image
                      src={post.image}
                      alt={post.imageAlt}
                      fill
                      className="object-cover transition-transform duration-300 group-hover:scale-105"
                      sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
                    />
                  </div>
                  <div className="flex flex-1 flex-col p-5">
                    <div className="flex items-center justify-between gap-2">
                      <span
                        className={cn(
                          "rounded-full px-2.5 py-0.5 text-[11px] font-bold uppercase tracking-wide",
                          categoryStyles[post.category]
                        )}
                      >
                        {post.category}
                      </span>
                      <span className="flex items-center gap-1 text-xs text-muted-foreground">
                        <Clock className="h-3.5 w-3.5" />
                        {post.readTime}
                      </span>
                    </div>
                    <h2 className="mt-3 font-heading text-lg font-bold leading-snug text-foreground group-hover:text-primary">
                      {post.title}
                    </h2>
                    <p className="mt-2 line-clamp-3 flex-1 text-sm leading-relaxed text-muted-foreground">
                      {post.excerpt}
                    </p>
                    <div className="mt-4 flex items-center justify-between border-t border-border pt-4 text-xs text-muted-foreground">
                      <span>{formatDate(post.date)}</span>
                      <span className="inline-flex items-center gap-1 font-semibold text-primary">
                        Read more
                        <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
                      </span>
                    </div>
                  </div>
                </Link>
              </StaggerItem>
            ))}
          </Stagger>

          {filteredPosts.length === 0 && (
            <p className="mt-12 text-center text-muted-foreground">
              No posts in this category yet. Check back soon.
            </p>
          )}
        </div>
      </section>
    </div>
  );
}
