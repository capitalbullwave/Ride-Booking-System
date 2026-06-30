"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";
import { bottomNavItems } from "@/constants/navigation";
import { cn } from "@/lib/utils";

export function BottomNav() {
  const pathname = usePathname();

  return (
    <div className="fixed bottom-0 left-0 z-50 w-full bg-card px-6 pb-safe pt-3 shadow-[0_-4px_20px_-10px_rgba(0,0,0,0.1)] md:hidden">
      <div className="mx-auto mb-4 flex max-w-md items-center justify-between">
        {bottomNavItems.map((item) => {
          const isActive = pathname === item.href;
          const Icon = item.icon;

          return (
            <Link
              key={item.href}
              href={item.href}
              className="flex min-w-[64px] flex-col items-center gap-1"
            >
              <div
                className={cn(
                  "flex h-10 w-10 items-center justify-center rounded-[14px] transition-all duration-300",
                  isActive
                    ? "bg-primary text-white shadow-md shadow-primary/20"
                    : "text-muted-foreground hover:bg-muted"
                )}
              >
                <Icon className={cn("h-5 w-5", isActive && "stroke-[2.5px]")} />
              </div>
              <span
                className={cn(
                  "text-[10px] font-medium transition-colors",
                  isActive ? "font-semibold text-primary" : "text-muted-foreground"
                )}
              >
                {item.label}
              </span>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
