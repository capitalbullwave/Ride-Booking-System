import { redirect } from "next/navigation";

/** Merged into All Activity */
export default function LegacyTransactionsRedirect() {
  redirect("/finance/activity");
}
