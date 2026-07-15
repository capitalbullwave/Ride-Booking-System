import { redirect } from "next/navigation";

/** Merged into All Activity */
export default function LegacyWalletRedirect() {
  redirect("/finance/activity?party=user");
}
