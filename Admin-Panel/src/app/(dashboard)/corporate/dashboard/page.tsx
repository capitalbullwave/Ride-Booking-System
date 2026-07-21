import { redirect } from "next/navigation";

/** Corporate stats live on the main Dashboard — keep old URL working. */
export default function CorporateDashboardRedirectPage() {
  redirect("/");
}
