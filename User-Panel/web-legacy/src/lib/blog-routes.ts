import { ROUTES } from "@/constants/routes";

export function blogPostPath(slug: string) {
  return `${ROUTES.blogs}/${slug}`;
}
