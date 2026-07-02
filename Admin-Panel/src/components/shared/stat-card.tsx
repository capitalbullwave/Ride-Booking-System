import { cn } from "@/lib/utils";
import { LucideIcon } from "lucide-react";

interface StatCardProps {
  title: string;
  value: string | number;
  change?: string;
  changeType?: "positive" | "negative" | "neutral";
  icon: LucideIcon;
  iconColor?: string;
  className?: string;
}

export function StatCard({
  title,
  value,
  change,
  changeType = "neutral",
  icon: Icon,
  iconColor = "bg-primary/10 text-primary",
  className,
}: StatCardProps) {
  return (
    <div
      className={cn(
        "group relative overflow-hidden rounded-[1.25rem] border border-border/80 bg-card p-6 wavego-card-shadow transition-all duration-300 hover:-translate-y-0.5 hover:shadow-lg",
        className
      )}
    >
      <div className="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-secondary/15 blur-2xl transition-opacity group-hover:opacity-100 opacity-60" />
      <div className="relative flex items-start justify-between">
        <div className="space-y-2">
          <p className="text-sm font-medium text-muted-foreground">{title}</p>
          <p className="font-heading text-3xl font-bold tracking-tight text-foreground">{value}</p>
          {change && (
            <p
              className={cn(
                "text-xs font-medium",
                changeType === "positive" && "text-success",
                changeType === "negative" && "text-destructive",
                changeType === "neutral" && "text-muted-foreground"
              )}
            >
              {change}
            </p>
          )}
        </div>
        <div className={cn("rounded-2xl p-3.5", iconColor)}>
          <Icon className="h-5 w-5" />
        </div>
      </div>
    </div>
  );
}
