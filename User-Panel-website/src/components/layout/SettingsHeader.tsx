"use client";

import { useRouter } from "next/navigation";
import { ArrowLeft } from "lucide-react";
import { cn } from "@/lib/utils";

interface SettingsHeaderProps {
  title?: string;
  className?: string;
  backHref?: string;
  onBack?: () => void;
}

export function SettingsHeader({
  title,
  className,
  backHref,
  onBack,
}: SettingsHeaderProps) {
  const router = useRouter();

  const handleBack = () => {
    if (onBack) {
      onBack();
      return;
    }
    if (backHref) {
      router.push(backHref);
      return;
    }
    router.back();
  };

  return (
    <div
      className={cn(
        "sticky top-0 z-10 border-b border-border bg-card/80 px-6 py-4 backdrop-blur-xl md:px-12 lg:px-24",
        className
      )}
    >
      <div className="flex w-full items-center gap-4">
        <button
          onClick={handleBack}
          className="flex h-10 w-10 items-center justify-center rounded-full transition-colors hover:bg-muted"
          aria-label="Go back"
        >
          <ArrowLeft className="h-5 w-5 text-foreground" />
        </button>
        {title && (
          <h1 className="font-heading text-2xl font-bold text-foreground">{title}</h1>
        )}
      </div>
    </div>
  );
}
