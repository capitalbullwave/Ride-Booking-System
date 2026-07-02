"use client";

import { useState } from "react";
import Link from "next/link";
import { Calendar } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";
import type { HelpArticleLink } from "@/data/help-center";
import { helpArticlePath } from "@/lib/help-routes";

export function HelpTripSelector({
  submitLabel = "Next",
  showDate = false,
}: {
  submitLabel?: string;
  showDate?: boolean;
}) {
  return (
    <div className="mt-6 space-y-4">
      {showDate && (
        <div>
          <label className="mb-2 block text-sm font-semibold text-foreground">
            Date of your trip
          </label>
          <div className="relative">
            <Input
              type="text"
              placeholder="dd-mm-yyyy"
              className="h-12 rounded-[14px] border-border bg-muted pr-10"
            />
            <Calendar className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          </div>
        </div>
      )}
      <p className="text-sm font-medium text-muted-foreground">Please select a trip below</p>
      <div className="rounded-[16px] border border-primary/20 bg-primary/5 px-4 py-8 text-center text-sm text-muted-foreground">
        No trips or orders to display.
      </div>
      <Button className="h-12 w-full rounded-[14px] font-bold uppercase tracking-wide sm:w-auto sm:min-w-[140px]">
        {submitLabel}
      </Button>
    </div>
  );
}

export function HelpToggleList({ toggles }: { toggles: string[] }) {
  const [states, setStates] = useState<Record<number, boolean>>({});

  return (
    <div className="mt-6 space-y-1 divide-y divide-border rounded-[16px] border border-border bg-card">
      {toggles.map((label, index) => (
        <div key={label} className="flex items-center justify-between gap-4 px-4 py-4">
          <span className="text-sm font-medium text-foreground">{label}</span>
          <button
            type="button"
            role="switch"
            aria-checked={states[index] ?? false}
            onClick={() => setStates((s) => ({ ...s, [index]: !s[index] }))}
            className={cn(
              "relative h-7 w-12 shrink-0 rounded-full transition-colors",
              states[index] ? "bg-primary" : "bg-muted"
            )}
          >
            <span
              className={cn(
                "absolute top-1 h-5 w-5 rounded-full bg-white shadow transition-transform",
                states[index] ? "left-6" : "left-1"
              )}
            />
          </button>
        </div>
      ))}
    </div>
  );
}

export function HelpArticleFeedback() {
  return (
    <div className="mt-10 flex flex-col gap-4 border-t border-border pt-8 sm:flex-row sm:items-center sm:justify-between">
      <p className="font-heading text-base font-bold text-foreground">
        Can we help with anything else?
      </p>
      <div className="flex gap-3">
        <Button variant="outline" className="min-w-[88px] rounded-[14px] font-semibold">
          Yes
        </Button>
        <Button variant="outline" className="min-w-[88px] rounded-[14px] font-semibold">
          No
        </Button>
      </div>
    </div>
  );
}

export function HelpArticleLinkButton({
  link,
  sectionId,
}: {
  link: HelpArticleLink;
  sectionId: string;
}) {
  const href = link.href ?? (link.articleId ? helpArticlePath(sectionId, link.articleId) : "#");

  return (
    <Link
      href={href}
      className="mt-4 inline-block text-sm font-semibold text-primary underline-offset-2 hover:underline"
    >
      {link.label}
    </Link>
  );
}

export function HelpContentBlocks({
  paragraphs,
  numberedList,
}: {
  paragraphs?: string[];
  numberedList?: string[];
}) {
  return (
    <>
      {paragraphs?.map((paragraph) => (
        <p key={paragraph} className="text-sm leading-relaxed text-muted-foreground">
          {paragraph}
        </p>
      ))}
      {numberedList && numberedList.length > 0 && (
        <ol className="list-decimal space-y-2 pl-5 text-sm leading-relaxed text-muted-foreground">
          {numberedList.map((item) => (
            <li key={item}>{item}</li>
          ))}
        </ol>
      )}
    </>
  );
}
