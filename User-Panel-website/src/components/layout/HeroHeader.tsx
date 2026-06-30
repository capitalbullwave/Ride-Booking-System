import { cn } from "@/lib/utils";
import type { LucideIcon } from "lucide-react";

interface HeroHeaderProps {
  eyebrow?: string;
  title: string;
  description?: string;
  icon?: LucideIcon;
  className?: string;
}

export function HeroHeader({
  eyebrow,
  title,
  description,
  icon: Icon,
  className,
}: HeroHeaderProps) {
  return (
    <div
      className={cn(
        "relative overflow-hidden rounded-b-[32px] bg-primary px-6 pb-10 pt-12 text-primary-foreground shadow-sm md:rounded-none md:px-12 md:pb-12 md:pt-14 lg:px-24",
        className
      )}
    >
      <div className="absolute -right-16 -top-16 h-48 w-48 rounded-full bg-white/10 blur-3xl" />
      <div className="absolute -bottom-10 -left-10 h-32 w-32 rounded-full bg-secondary/20 blur-2xl" />

      <div className="relative z-10 w-full">
        <div className="flex items-start justify-between gap-4">
          <div>
            {eyebrow && (
              <p className="text-sm font-medium text-primary-foreground/75">{eyebrow}</p>
            )}
            <h1 className="font-heading text-3xl font-bold tracking-tight">{title}</h1>
            {description && (
              <p className="mt-2 max-w-sm text-sm text-primary-foreground/80">{description}</p>
            )}
          </div>
          {Icon && (
            <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-white/10 backdrop-blur-sm">
              <Icon className="h-6 w-6" />
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
