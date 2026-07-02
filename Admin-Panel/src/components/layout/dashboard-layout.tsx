"use client";

import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";
import { AppSidebar } from "@/components/layout/app-sidebar";
import { AppHeader } from "@/components/layout/app-header";
import { TooltipProvider } from "@/components/ui/tooltip";

export function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <TooltipProvider>
      <SidebarProvider>
        <AppSidebar />
        <SidebarInset className="wavego-mesh bg-background">
          <AppHeader />
          <main className="flex-1 overflow-auto p-4 lg:p-8">{children}</main>
        </SidebarInset>
      </SidebarProvider>
    </TooltipProvider>
  );
}
