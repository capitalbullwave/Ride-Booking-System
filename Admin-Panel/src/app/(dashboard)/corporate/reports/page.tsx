import { redirect } from "next/navigation";

/** Corporate reports live under Insights → Reports (Corporate tab). */
export default function CorporateReportsRedirectPage() {
  redirect("/reports?tab=corporate");
}
