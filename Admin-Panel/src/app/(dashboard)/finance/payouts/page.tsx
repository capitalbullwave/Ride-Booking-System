import { redirect } from "next/navigation";

/** Merged into Approvals & Payments */
export default function LegacyPayoutsRedirect() {
  redirect("/finance/approvals");
}
