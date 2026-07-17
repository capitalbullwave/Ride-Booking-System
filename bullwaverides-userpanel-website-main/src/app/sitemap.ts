import type { MetadataRoute } from "next";

const siteUrl = (process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000")
  .trim()
  .replace(/\/+$/, "");

function url(path: string) {
  return `${siteUrl}${path.startsWith("/") ? path : `/${path}`}`;
}

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();

  // Keep this list focused on public, marketing-style pages.
  // App/auth/account flows are intentionally excluded via robots rules.
  const staticRoutes = [
    "/",
    "/home",
    "/about",
    "/blogs",
    "/safety",
    "/legal/privacy",
    "/legal/terms",
    "/legal/safety",
  ];

  return staticRoutes.map((path) => ({
    url: url(path),
    lastModified: now,
    changeFrequency: "weekly",
    priority: path === "/" ? 1 : 0.7,
  }));
}

