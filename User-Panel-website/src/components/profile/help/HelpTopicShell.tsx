"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft, ChevronRight, FileText, List, Smartphone } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { WaveGoLogo } from "@/components/layout/WaveGoLogo";
import { ROUTES } from "@/constants/routes";
import { cn } from "@/lib/utils";

export function HelpBreadcrumb({
  sectionTitle,
  sectionId,
  parentTitle,
  parentId,
  light = false,
}: {
  sectionTitle?: string;
  sectionId?: string;
  parentTitle?: string;
  parentId?: string;
  light?: boolean;
}) {
  const linkClass = cn(
    "font-medium underline-offset-2 transition-colors hover:underline",
    light ? "text-primary hover:text-primary/80" : "text-white/70 hover:text-white"
  );
  const sepClass = light ? "text-muted-foreground/50" : "text-white/40";

  return (
    <nav className="mb-4 flex flex-wrap items-center gap-2 text-sm">
      <Link href={ROUTES.profileHelp} className={linkClass}>
        Home
      </Link>
      {sectionTitle && sectionId && (
        <>
          <span className={sepClass}>/</span>
          <Link href={`/profile/help/${sectionId}`} className={linkClass}>
            {sectionTitle}
          </Link>
        </>
      )}
      {parentTitle && parentId && sectionId && (
        <>
          <span className={sepClass}>/</span>
          <Link href={`/profile/help/${sectionId}/${parentId}`} className={linkClass}>
            {parentTitle}
          </Link>
        </>
      )}
    </nav>
  );
}

export function HelpArticleRow({
  title,
  href,
  icon: Icon = List,
  onClick,
}: {
  title: string;
  href?: string;
  icon?: LucideIcon;
  onClick?: () => void;
}) {
  const className = cn(
    "group flex w-full items-center gap-4 border-b border-white/10 py-4 text-left transition-colors last:border-b-0 hover:bg-white/5"
  );

  const content = (
    <>
      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-[12px] bg-white/10 text-white transition-colors group-hover:bg-white/15">
        <Icon className="h-4 w-4" />
      </div>
      <span className="flex-1 text-sm font-semibold text-white">{title}</span>
      <ChevronRight className="h-4 w-4 shrink-0 text-white/40 transition-transform group-hover:translate-x-0.5 group-hover:text-white/70" />
    </>
  );

  if (href) {
    return (
      <Link href={href} className={className}>
        {content}
      </Link>
    );
  }

  return (
    <button type="button" onClick={onClick} className={className}>
      {content}
    </button>
  );
}

interface HelpTopicShellProps {
  title: string;
  breadcrumb?: {
    sectionTitle: string;
    sectionId: string;
    parentTitle?: string;
    parentId?: string;
  };
  children: React.ReactNode;
  variant?: "primary" | "light";
  hideTitle?: boolean;
}

export function HelpTopicShell({
  title,
  breadcrumb,
  children,
  variant = "primary",
  hideTitle = false,
}: HelpTopicShellProps) {
  const router = useRouter();
  const isPrimary = variant === "primary";

  return (
    <div
      className={cn(
        "flex min-h-screen w-full flex-col",
        isPrimary ? "bg-primary text-white" : "bg-background text-foreground"
      )}
    >
      <header
        className={cn(
          "flex w-full items-center gap-4 px-5 py-4 sm:px-8 md:px-12 lg:px-16",
          !isPrimary && "border-b border-border bg-card"
        )}
      >
        <button
          onClick={() => router.back()}
          className={cn(
            "flex h-10 w-10 items-center justify-center rounded-full transition-colors",
            isPrimary ? "hover:bg-white/10" : "hover:bg-muted"
          )}
          aria-label="Go back"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
        <WaveGoLogo size="sm" variant={isPrimary ? "light" : "default"} />
      </header>

      <section className="w-full flex-1 px-5 pb-10 sm:px-8 md:px-12 lg:px-16">
        <HelpBreadcrumb
          sectionTitle={breadcrumb?.sectionTitle}
          sectionId={breadcrumb?.sectionId}
          parentTitle={breadcrumb?.parentTitle}
          parentId={breadcrumb?.parentId}
          light={!isPrimary}
        />
        {!hideTitle && (
          <h1
            className={cn(
              "font-heading text-3xl font-bold leading-tight sm:text-4xl",
              !isPrimary && "text-foreground"
            )}
          >
            {title}
          </h1>
        )}
        <div className={cn(!hideTitle && "mt-6")}>{children}</div>
      </section>
    </div>
  );
}

export function articleIcon(title: string): LucideIcon {
  if (title.toLowerCase().includes("phone")) return Smartphone;
  if (title.toLowerCase().includes("policy") || title.toLowerCase().includes("privacy")) {
    return FileText;
  }
  return List;
}
