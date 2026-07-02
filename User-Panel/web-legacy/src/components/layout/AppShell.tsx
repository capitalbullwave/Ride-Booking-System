import { BottomNav } from "@/components/layout/BottomNav";
import { cn } from "@/lib/utils";

interface AppShellProps {
  children: React.ReactNode;
  showBottomNav?: boolean;
  className?: string;
}

export function AppShell({
  children,
  showBottomNav = true,
  className,
}: AppShellProps) {
  return (
    <div className={cn("flex min-h-screen flex-col bg-background", showBottomNav && "pb-24", className)}>
      {children}
      {showBottomNav && <BottomNav />}
    </div>
  );
}
