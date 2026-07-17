"use client";

import Link from "next/link";
import { HelpTopicShell } from "@/components/profile/help/HelpTopicShell";
import { ROUTES } from "@/constants/routes";

const openConversation = {
  status: "Open",
  title: "Fare review for trip on Apr 12",
  created: "Created on Sat, Jun 20, 2:16 PM",
};

const archivedMessages = [
  {
    id: 1,
    title: "I want to reactivate my account",
    status: "Archived",
    created: "Created on Sat, Jun 20, 12:23 PM",
  },
  {
    id: 2,
    title: "Lost item — Cab trip Mar 28",
    status: "Archived",
    created: "Created on Fri, Jun 19, 6:45 PM",
  },
];

export function HelpMessagesView() {
  return (
    <HelpTopicShell title="Support messages" variant="light">
      <div className="max-w-3xl">
        <section className="mb-8">
          <h2 className="mb-3 font-heading text-sm font-bold uppercase tracking-wide text-muted-foreground">
            Your conversation
          </h2>
          <button className="w-full rounded-[18px] border border-primary/20 bg-primary/[0.04] p-4 text-left transition-colors hover:border-primary/30">
            <div className="flex items-center justify-between gap-3">
              <span className="text-sm font-semibold text-primary">{openConversation.status}</span>
              <span className="text-xs text-muted-foreground">{openConversation.created}</span>
            </div>
            <p className="mt-2 text-sm font-medium text-foreground">{openConversation.title}</p>
          </button>
        </section>

        <section>
          <h2 className="mb-3 font-heading text-sm font-bold uppercase tracking-wide text-muted-foreground">
            Archive
          </h2>
          <div className="divide-y divide-border overflow-hidden rounded-[18px] border border-border bg-card">
            {archivedMessages.map((message) => (
              <button
                key={message.id}
                className="w-full px-4 py-4 text-left transition-colors hover:bg-muted/40"
              >
                <p className="text-sm font-medium text-foreground">{message.title}</p>
                <div className="mt-2 flex items-center justify-between gap-3">
                  <span className="text-xs font-medium text-muted-foreground">{message.status}</span>
                  <span className="text-xs text-muted-foreground">{message.created}</span>
                </div>
              </button>
            ))}
          </div>
        </section>

        <p className="mt-6 text-sm text-muted-foreground">
          Need new help?{" "}
          <Link href={ROUTES.profileHelp} className="font-semibold text-primary hover:underline">
            Browse all topics
          </Link>
        </p>
      </div>
    </HelpTopicShell>
  );
}
