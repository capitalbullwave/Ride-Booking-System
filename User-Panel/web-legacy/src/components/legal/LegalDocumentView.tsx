import Link from "next/link";
import type { LucideIcon } from "lucide-react";
import { InfoPageLayout } from "@/components/layout";
import { cn } from "@/lib/utils";

interface LegalSection {
  title: string;
  content: string;
}

interface LegalDocumentViewProps {
  title: string;
  subtitle?: string;
  lastUpdated?: string;
  icon?: LucideIcon;
  sections?: LegalSection[];
  children?: React.ReactNode;
  relatedLinks?: { label: string; href: string }[];
}

export function LegalDocumentView({
  title,
  subtitle,
  lastUpdated = "June 2026",
  icon: Icon,
  sections,
  children,
  relatedLinks,
}: LegalDocumentViewProps) {
  return (
    <InfoPageLayout title={title}>
      <div className="max-w-3xl">
        {(subtitle || Icon) && (
          <div className="mb-8 flex gap-4 rounded-[20px] border border-border bg-card p-5 shadow-sm">
            {Icon && (
              <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-[14px] bg-primary/10 text-primary">
                <Icon className="h-6 w-6" />
              </div>
            )}
            <div>
              {subtitle && (
                <p className="text-sm leading-relaxed text-muted-foreground">{subtitle}</p>
              )}
              <p className="mt-2 text-xs font-medium text-muted-foreground/70">
                Last updated: {lastUpdated}
              </p>
            </div>
          </div>
        )}

        {sections && sections.length > 0 ? (
          <div className="space-y-4">
            {sections.map((section, index) => (
              <article
                key={section.title}
                className={cn(
                  "rounded-[20px] border border-border bg-card p-5 shadow-sm",
                  index === 0 && "border-primary/15"
                )}
              >
                <h2 className="font-heading text-base font-bold text-foreground">
                  {section.title}
                </h2>
                <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                  {section.content}
                </p>
              </article>
            ))}
          </div>
        ) : (
          children
        )}

        {relatedLinks && relatedLinks.length > 0 && (
          <div className="mt-8 rounded-[20px] border border-border bg-muted/30 p-5">
            <p className="mb-3 font-heading text-sm font-bold text-foreground">See also</p>
            <div className="flex flex-wrap gap-2">
              {relatedLinks.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  className="rounded-full border border-border bg-card px-4 py-2 text-xs font-semibold text-primary transition-colors hover:border-primary/30 hover:bg-primary/5"
                >
                  {link.label}
                </Link>
              ))}
            </div>
          </div>
        )}

        <p className="mt-6 text-xs text-muted-foreground">
          This is a UI preview document. The complete version will be published before public launch.
        </p>
      </div>
    </InfoPageLayout>
  );
}
