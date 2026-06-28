"use client";

import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { navigation } from "@/config/navigation";
import { APP_NAME, APP_TAGLINE } from "@/constants/routes";
import { cn } from "@/lib/utils";
import { Badge } from "@/components/ui/badge";
import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarFooter,
} from "@/components/ui/sidebar";

export function AppSidebar() {
  const pathname = usePathname();

  return (
    <Sidebar className="wavego-sidebar border-r border-sidebar-border text-sidebar-foreground">
      <SidebarHeader className="border-b border-sidebar-border px-5 py-5">
        <Link href="/" className="flex items-center gap-3.5">
          <div className="relative flex h-11 w-11 shrink-0 items-center justify-center overflow-hidden rounded-2xl bg-secondary shadow-md shadow-black/20 ring-2 ring-white/10">
            <Image src="/logo.svg" alt={APP_NAME} width={44} height={44} className="h-full w-full object-cover" />
          </div>
          <div className="flex flex-col">
            <span className="font-heading text-lg font-bold tracking-tight text-sidebar-foreground">
              {APP_NAME}
            </span>
            <span className="text-xs text-sidebar-foreground/65">{APP_TAGLINE}</span>
          </div>
        </Link>
      </SidebarHeader>
      <SidebarContent className="px-2 py-3">
        {navigation.map((group) => (
          <SidebarGroup key={group.title}>
            <SidebarGroupLabel className="px-3 text-[11px] font-semibold uppercase tracking-wider text-sidebar-foreground/50">
              {group.title}
            </SidebarGroupLabel>
            <SidebarGroupContent>
              <SidebarMenu>
                {group.items.map((item) => {
                  const isActive =
                    item.href === "/"
                      ? pathname === "/"
                      : pathname.startsWith(item.href);
                  return (
                    <SidebarMenuItem key={item.href}>
                      <SidebarMenuButton
                        render={<Link href={item.href} />}
                        isActive={isActive}
                        className={cn(
                          "mb-0.5 rounded-2xl px-3 py-2.5 transition-all",
                          isActive
                            ? "bg-secondary text-secondary-foreground shadow-sm shadow-black/15 hover:bg-secondary hover:text-secondary-foreground"
                            : "text-sidebar-foreground/85 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
                        )}
                      >
                        <item.icon className={cn("h-4 w-4", isActive && "text-secondary-foreground")} />
                        <span className="font-medium">{item.title}</span>
                        {item.badge && (
                          <Badge
                            variant="secondary"
                            className={cn(
                              "ml-auto h-5 min-w-5 justify-center text-xs",
                              isActive
                                ? "bg-primary/15 text-primary"
                                : "bg-white/15 text-sidebar-foreground"
                            )}
                          >
                            {item.badge}
                          </Badge>
                        )}
                      </SidebarMenuButton>
                    </SidebarMenuItem>
                  );
                })}
              </SidebarMenu>
            </SidebarGroupContent>
          </SidebarGroup>
        ))}
      </SidebarContent>
      <SidebarFooter className="wavego-sidebar-footer border-t border-sidebar-border p-4">
        <div className="relative overflow-hidden rounded-[1.25rem] border border-secondary/30 bg-secondary/12 p-4">
          <div className="absolute -right-4 -top-4 h-16 w-16 rounded-full bg-secondary/20 blur-2xl" />
          <p className="relative font-heading text-sm font-semibold text-secondary">WaveGo Admin</p>
          <p className="relative mt-1 text-xs leading-relaxed text-sidebar-foreground/75">
            Rides & ambulance operations
          </p>
          <p className="relative mt-2.5 text-[10px] font-medium uppercase tracking-wider text-sidebar-foreground/45">
            v1.0 · Enterprise
          </p>
        </div>
      </SidebarFooter>
    </Sidebar>
  );
}
