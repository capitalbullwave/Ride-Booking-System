import { cn } from "@/lib/utils";

interface PageHeaderProps {
  title: string;
  subtitle?: string;
  className?: string;
}

export function PageHeader({ title, subtitle, className }: PageHeaderProps) {
  return (
    <div
      className={cn(
        "sticky top-0 z-10 border-b border-border bg-card/80 px-6 py-4 backdrop-blur-xl md:px-12 lg:px-24",
        className
      )}
    >
      <div className="w-full">
        <h1 className="font-heading text-2xl font-bold text-foreground">{title}</h1>
        {subtitle && <p className="mt-1 text-sm text-muted-foreground">{subtitle}</p>}
      </div>
    </div>
  );
}
