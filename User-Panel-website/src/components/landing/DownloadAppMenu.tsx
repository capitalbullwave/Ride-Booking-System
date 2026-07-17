"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ChevronDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import { APP_DOWNLOAD } from "@/constants/app-download";
import { cn } from "@/lib/utils";
import type { VariantProps } from "class-variance-authority";
import { buttonVariants } from "@/components/ui/button";

type DownloadAppMenuProps = {
  className?: string;
  buttonClassName?: string;
  label?: string;
  align?: "left" | "right";
  androidApkUrl?: string;
  androidFileName?: string;
  iosUrl?: string;
  iosUnavailableMessage?: string;
  androidOptionLabel?: string;
  iosOptionLabel?: string;
} & Pick<VariantProps<typeof buttonVariants>, "variant" | "size">;

export function DownloadAppMenu({
  className,
  buttonClassName,
  label = "Download App",
  variant = "default",
  size = "default",
  align = "right",
  androidApkUrl = APP_DOWNLOAD.androidApkUrl,
  androidFileName = APP_DOWNLOAD.androidFileName,
  iosUrl = APP_DOWNLOAD.iosAppStoreUrl,
  iosUnavailableMessage = "iOS app link will be available soon.",
  androidOptionLabel = "Download for Android",
  iosOptionLabel = "Download for iOS",
}: DownloadAppMenuProps) {
  const [open, setOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const buttonRef = useRef<HTMLButtonElement>(null);
  const menuRef = useRef<HTMLDivElement>(null);
  const [menuPosition, setMenuPosition] = useState<{
    top: number;
    left: number;
    width: number;
  } | null>(null);

  useEffect(() => {
    if (!open) {
      return;
    }

    const handleClickOutside = (event: MouseEvent) => {
      const target = event.target as Node;
      if (
        (containerRef.current && containerRef.current.contains(target)) ||
        (menuRef.current && menuRef.current.contains(target))
      ) {
        return;
      }

      setOpen(false);
    };

    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        setOpen(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    document.addEventListener("keydown", handleEscape);

    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
      document.removeEventListener("keydown", handleEscape);
    };
  }, [open]);

  useEffect(() => {
    if (!open) {
      setMenuPosition(null);
      return;
    }

    const updatePosition = () => {
      const btn = buttonRef.current;
      if (!btn) {
        return;
      }
      const rect = btn.getBoundingClientRect();

      // Use fixed positioning + portal so it never gets clipped by overflow-hidden parents.
      const width = 220;
      const margin = 8;
      const preferLeft = align === "left";
      const left = preferLeft
        ? Math.max(margin, rect.left)
        : Math.min(window.innerWidth - width - margin, rect.right - width);

      const estimatedMenuHeight = 110;
      const spaceBelow = window.innerHeight - rect.bottom;
      const openUpwards = spaceBelow < estimatedMenuHeight + margin;
      const top = openUpwards
        ? Math.max(margin, rect.top - estimatedMenuHeight - margin)
        : rect.bottom + margin;

      setMenuPosition({ top, left, width });
    };

    updatePosition();
    window.addEventListener("resize", updatePosition);
    window.addEventListener("scroll", updatePosition, true);
    return () => {
      window.removeEventListener("resize", updatePosition);
      window.removeEventListener("scroll", updatePosition, true);
    };
  }, [open, align]);

  const handleAndroidDownload = () => {
    const link = document.createElement("a");
    link.href = androidApkUrl;
    link.download = androidFileName;
    link.rel = "noopener";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    setOpen(false);
  };

  const handleIosDownload = () => {
    if (iosUrl) {
      window.open(iosUrl, "_blank", "noopener,noreferrer");
    } else {
      window.alert(iosUnavailableMessage);
    }
    setOpen(false);
  };

  const menu = useMemo(() => {
    if (!open || !menuPosition) {
      return null;
    }

    return createPortal(
      <div
        ref={menuRef}
        role="menu"
        className="fixed z-[100] overflow-hidden rounded-xl border border-border bg-card py-1 shadow-lg"
        style={{
          top: menuPosition.top,
          left: menuPosition.left,
          width: menuPosition.width,
        }}
      >
        <button
          type="button"
          role="menuitem"
          className="flex w-full px-4 py-3 text-left text-sm font-medium text-foreground transition-colors hover:bg-primary/10 hover:text-primary"
          onClick={handleAndroidDownload}
        >
          {androidOptionLabel}
        </button>
        <button
          type="button"
          role="menuitem"
          className="flex w-full px-4 py-3 text-left text-sm font-medium text-foreground transition-colors hover:bg-primary/10 hover:text-primary"
          onClick={handleIosDownload}
        >
          {iosOptionLabel}
        </button>
      </div>,
      document.body
    );
  }, [
    open,
    menuPosition,
    androidOptionLabel,
    iosOptionLabel,
    // handlers depend on current props/state; safe here because memo deps include relevant values
    androidApkUrl,
    androidFileName,
    iosUrl,
    iosUnavailableMessage,
  ]);

  return (
    <div ref={containerRef} className={cn("relative", className)}>
      <Button
        ref={buttonRef}
        type="button"
        variant={variant}
        size={size}
        aria-expanded={open}
        aria-haspopup="menu"
        className={cn("rounded-lg px-5 font-semibold", buttonClassName)}
        onClick={() => setOpen((current) => !current)}
      >
        {label}
        <ChevronDown
          className={cn(
            "ml-1 h-4 w-4 transition-transform duration-200",
            open && "rotate-180"
          )}
        />
      </Button>
      {menu}
    </div>
  );
}
