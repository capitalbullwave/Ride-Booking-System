import { redirect } from "next/navigation";

/** Merged into Approvals & Payments */
export default function LegacyRefundsRedirect() {
  redirect("/finance/approvals");
}
