"use client";

import { AppShell } from "@/components/layout/AppShell";
import { SettingsHeader } from "@/components/layout/SettingsHeader";

interface InfoPageLayoutProps {
  title: string;
  children: React.ReactNode;
}

export function InfoPageLayout({ title, children }: InfoPageLayoutProps) {
  return (
    <AppShell showBottomNav={false} className="pb-8">
      <SettingsHeader title={title} />
      <div className="w-full flex-1 px-6 py-6 md:px-12 lg:px-24">
        {children}
      </div>
    </AppShell>
  );
}
