import type { Metadata } from "next";
import { BlogsView } from "@/components/landing/BlogsView";

export const metadata: Metadata = {
  title: "Blog | Bull Wave Rides",
  description:
    "Bull Wave Rides company news, product updates, safety guides, captain stories, and community insights from India's trusted mobility platform.",
};

export default function BlogsPage() {
  return <BlogsView />;
}
