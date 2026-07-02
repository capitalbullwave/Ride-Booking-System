"use client";

import Link from "next/link";
import { useTheme } from "next-themes";
import {
  Bell,
  Moon,
  Sun,
  Search,
  LogOut,
  User,
  Settings,
  HelpCircle,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { SidebarTrigger } from "@/components/ui/sidebar";
import { Separator } from "@/components/ui/separator";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Badge } from "@/components/ui/badge";
import { AppBreadcrumbs } from "./app-breadcrumbs";
import { useAuth } from "@/components/providers/auth-provider";
import { DEFAULT_ADMIN_NAME } from "@/lib/auth";
import { ROUTES } from "@/constants/routes";
import { adminAlerts } from "@/data/mock-data";

export function AppHeader() {
  const { theme, setTheme } = useTheme();
  const { user, logout } = useAuth();
  const unreadCount = adminAlerts.filter((n) => n.unread).length;
  const headerAlerts = adminAlerts.slice(0, 4);
  const initials = user?.name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .slice(0, 2) ?? "AD";

  return (
    <header className="wavego-header sticky top-0 z-30 flex h-[4.25rem] shrink-0 items-center gap-4 px-4 backdrop-blur-xl lg:px-6">
      <SidebarTrigger className="-ml-1 text-primary hover:bg-primary/8 hover:text-primary" />
      <Separator orientation="vertical" className="hidden h-7 bg-primary/12 sm:block" />
      <div className="hidden flex-1 sm:block">
        <AppBreadcrumbs />
      </div>

      <div className="ml-auto flex items-center gap-2">
        <div className="relative hidden md:block">
          <Search className="absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Search users, rides, drivers..."
            className="h-10 w-64 rounded-[1.125rem] border-border/90 bg-background/60 pl-9 shadow-none focus-visible:border-primary/30 focus-visible:ring-primary/15 lg:w-80"
          />
        </div>

        <Button
          variant="ghost"
          size="icon"
          className="text-foreground/70 hover:bg-muted hover:text-primary"
          onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
        >
          <Sun className="h-4 w-4 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
          <Moon className="absolute h-4 w-4 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
          <span className="sr-only">Toggle theme</span>
        </Button>

        <DropdownMenu>
          <DropdownMenuTrigger
            render={
              <Button variant="ghost" size="icon" className="relative text-foreground/70 hover:bg-muted hover:text-primary" />
            }
          >
            <Bell className="h-4 w-4" />
            {unreadCount > 0 && (
              <Badge className="absolute -right-1 -top-1 flex h-4 w-4 items-center justify-center rounded-full p-0 text-[10px]">
                {unreadCount}
              </Badge>
            )}
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-80">
            <DropdownMenuGroup>
              <DropdownMenuLabel className="flex items-center justify-between">
                Admin Alerts
                <Badge variant="secondary" className="text-xs">
                  {unreadCount} new
                </Badge>
              </DropdownMenuLabel>
            </DropdownMenuGroup>
            <DropdownMenuSeparator />
            {headerAlerts.map((alert) =>
              alert.href ? (
                <DropdownMenuItem
                  key={alert.id}
                  className="flex flex-col items-start gap-1 p-3"
                  render={<Link href={alert.href} />}
                >
                  <div className="flex w-full items-center gap-2">
                    {alert.unread && (
                      <span className="h-2 w-2 rounded-full bg-primary" />
                    )}
                    <span className="text-sm font-medium">{alert.title}</span>
                  </div>
                  <span className="text-xs text-muted-foreground pl-4">
                    {alert.time}
                  </span>
                </DropdownMenuItem>
              ) : (
                <DropdownMenuItem
                  key={alert.id}
                  className="flex flex-col items-start gap-1 p-3"
                >
                  <div className="flex w-full items-center gap-2">
                    {alert.unread && (
                      <span className="h-2 w-2 rounded-full bg-primary" />
                    )}
                    <span className="text-sm font-medium">{alert.title}</span>
                  </div>
                  <span className="text-xs text-muted-foreground pl-4">
                    {alert.time}
                  </span>
                </DropdownMenuItem>
              )
            )}
            <DropdownMenuSeparator />
            <DropdownMenuItem
              className="justify-center text-primary font-medium"
              render={<Link href={ROUTES.alerts} />}
            >
              View all alerts
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>

        <DropdownMenu>
          <DropdownMenuTrigger
            render={
              <Button variant="ghost" className="relative h-9 w-9 rounded-full" />
            }
          >
            <Avatar className="h-9 w-9">
              <AvatarFallback className="bg-primary text-primary-foreground text-sm">
                {initials}
              </AvatarFallback>
            </Avatar>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-56">
            <DropdownMenuGroup>
              <DropdownMenuLabel>
                <div className="flex flex-col">
                  <span>{user?.name ?? DEFAULT_ADMIN_NAME}</span>
                  <span className="text-xs font-normal text-muted-foreground">
                    {user?.email ?? "admin@wavego.com"}
                  </span>
                </div>
              </DropdownMenuLabel>
            </DropdownMenuGroup>
            <DropdownMenuSeparator />
            <DropdownMenuItem render={<Link href={ROUTES.alerts} />}>
              <Bell className="mr-2 h-4 w-4" />
              Alert Inbox
            </DropdownMenuItem>
            <DropdownMenuItem render={<Link href={ROUTES.profile} />}>
              <User className="mr-2 h-4 w-4" />
              Profile
            </DropdownMenuItem>
            <DropdownMenuItem render={<Link href={ROUTES.settings} />}>
              <Settings className="mr-2 h-4 w-4" />
              App Settings
            </DropdownMenuItem>
            <DropdownMenuItem render={<Link href={ROUTES.help} />}>
              <HelpCircle className="mr-2 h-4 w-4" />
              Help Center
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem className="text-destructive" onClick={logout}>
              <LogOut className="mr-2 h-4 w-4" />
              Log out
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
