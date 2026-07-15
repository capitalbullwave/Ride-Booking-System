import { cn } from "@/lib/utils";
import { capitalize } from "@/lib/format";

const statusStyles: Record<string, string> = {
  active: "bg-success/15 text-success",
  online: "bg-success/15 text-success",
  inactive: "bg-muted text-muted-foreground",
  offline: "bg-muted text-muted-foreground",
  suspended: "bg-warning/15 text-warning",
  blocked: "bg-destructive/15 text-destructive",
  rejected: "bg-destructive/15 text-destructive",
  pending: "bg-warning/15 text-warning",
  busy: "bg-primary/10 text-primary",
  requested: "bg-primary/10 text-primary",
  driver_assigned: "bg-primary/15 text-primary",
  driver_arrived: "bg-secondary/30 text-secondary-foreground",
  ride_started: "bg-muted-foreground/15 text-muted-foreground",
  ride_completed: "bg-success/15 text-success",
  completed: "bg-success/15 text-success",
  cancelled: "bg-destructive/15 text-destructive",
  failed: "bg-destructive/15 text-destructive",
  open: "bg-primary/10 text-primary",
  in_progress: "bg-warning/15 text-warning",
  resolved: "bg-success/15 text-success",
  closed: "bg-muted text-muted-foreground",
  expired: "bg-muted text-muted-foreground",
  disabled: "bg-destructive/15 text-destructive",
  paid: "bg-success/15 text-success",
  approved: "bg-success/15 text-success",
  high: "bg-destructive/15 text-destructive",
  medium: "bg-warning/15 text-warning",
  low: "bg-muted text-muted-foreground",
};

interface StatusBadgeProps {
  status: string;
  className?: string;
}

export function StatusBadge({ status, className }: StatusBadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold",
        statusStyles[status] ?? "bg-muted text-muted-foreground",
        className
      )}
    >
      {capitalize(status)}
    </span>
  );
}
