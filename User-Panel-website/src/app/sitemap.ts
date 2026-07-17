import type { MetadataRoute } from "next";
import { blogPosts } from "@/data/blogs";

const siteUrl = (process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000")
  .trim()
  .replace(/\/+$/, "");

function url(path: string) {
  return `${siteUrl}${path.startsWith("/") ? path : `/${path}`}`;
}

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();

  const staticRoutes = [
    "/",
    "/about",
    "/blogs",
    "/safety",
    "/legal/privacy",
    "/legal/terms",
    "/legal/safety",
  ];

  const blogRoutes = blogPosts.map((post) => `/blogs/${post.slug}`);

  return [...staticRoutes, ...blogRoutes].map((path) => ({
    url: url(path),
    lastModified: now,
    changeFrequency: path.startsWith("/blogs/") ? "monthly" : "weekly",
    priority: path === "/" ? 1 : path.startsWith("/blogs/") ? 0.6 : 0.7,
  }));
}
