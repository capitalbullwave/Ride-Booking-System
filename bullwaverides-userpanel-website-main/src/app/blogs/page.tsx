import type { Metadata } from "next";
import { BlogsView } from "@/components/landing/BlogsView";

export const metadata: Metadata = {
  title: "Blog | Bull Wave rides",
  description:
    "Bull Wave rides company news, product updates, safety guides, captain stories, and community insights from India's trusted mobility platform.",
};

export default function BlogsPage() {
  return <BlogsView />;
}
