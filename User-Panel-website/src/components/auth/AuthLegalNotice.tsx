import Link from "next/link";
import { ShieldCheck } from "lucide-react";
import { ROUTES } from "@/constants/routes";
import { cn } from "@/lib/utils";

interface AuthLegalNoticeProps {
  className?: string;
}

const linkClass =
  "font-semibold text-primary underline-offset-2 transition-colors hover:text-primary/80 hover:underline";

export function AuthLegalNotice({ className }: AuthLegalNoticeProps) {
  return (
    <div
      className={cn(
        "rounded-[14px] border border-border/70 bg-muted/35 px-4 py-3.5 text-center",
        className
      )}
    >
      <div className="mx-auto mb-2 flex w-fit items-center gap-1.5 text-muted-foreground">
        <ShieldCheck className="h-3.5 w-3.5 text-primary" aria-hidden />
        <span className="text-[11px] font-semibold uppercase tracking-wide">Secure &amp; protected</span>
      </div>
      <p className="mx-auto max-w-[18rem] text-xs leading-relaxed text-muted-foreground sm:max-w-none sm:text-[13px]">
        By continuing, you agree to our{" "}
        <Link href={ROUTES.terms} className={linkClass}>
          Terms of Service
        </Link>
        ,{" "}
        <Link href={ROUTES.privacy} className={linkClass}>
          Privacy Policy
        </Link>
        , and{" "}
        <Link href={ROUTES.safety} className={linkClass}>
          Safety Policy
        </Link>
        .
      </p>
    </div>
  );
}
