"use client";

import { useRouter } from "next/navigation";
import {
  AlertTriangle,
  CheckCircle2,
  ChevronRight,
  ExternalLink,
  UserCircle,
} from "lucide-react";
import { SettingsHeader } from "@/components/layout";
import { ROUTES } from "@/constants/routes";
import { useAuthUser } from "@/hooks/useAuthUser";

export function AccountSettingsView() {
  const router = useRouter();
  const user = useAuthUser();
  const hasEmail = user.email !== "Add email";

  const infoRows = [
    {
      id: "name",
      label: "Name",
      value: user.name,
      status: null as "warning" | "verified" | null,
      route: null as string | null,
    },
    {
      id: "phone",
      label: "Phone number",
      value: user.phone,
      status: "verified" as const,
      route: ROUTES.profilePhone,
    },
    {
      id: "email",
      label: "Email",
      value: user.email,
      status: (hasEmail ? "verified" : "warning") as "warning" | "verified" | null,
      route: ROUTES.profileEmail,
    },
    {
      id: "emergency",
      label: "Emergency contact",
      value: "Used for SOS during active rides",
      status: null as "warning" | "verified" | null,
      route: ROUTES.profileEmergencyContact,
    },
    {
      id: "language",
      label: "Language",
      value: "Update device language",
      status: null as "warning" | "verified" | null,
      external: true,
      route: null as string | null,
    },
  ];

  return (
    <div className="flex min-h-screen flex-col bg-background pb-8">
      <SettingsHeader title="Personal info" />

      <div className="w-full flex-1 px-6 py-6 md:px-12 lg:px-24">
        <div className="mb-8 flex h-24 w-24 items-center justify-center rounded-full bg-muted">
          <UserCircle className="h-16 w-16 text-muted-foreground/40" strokeWidth={1} />
        </div>

        <div className="divide-y divide-border rounded-[20px] border border-border bg-card">
          {infoRows.map((row) => (
            <button
              key={row.id}
              onClick={() => row.route && router.push(row.route)}
              className="flex w-full items-center justify-between px-5 py-5 text-left transition-colors first:rounded-t-[20px] last:rounded-b-[20px] hover:bg-muted/30"
            >
              <div className="flex-1">
                <p className="font-semibold text-foreground">{row.label}</p>
                <div className="mt-1 flex items-center gap-2">
                  <p className="text-sm text-muted-foreground">{row.value}</p>
                  {row.status === "warning" && (
                    <AlertTriangle className="h-4 w-4 shrink-0 fill-warning text-primary-foreground" />
                  )}
                  {row.status === "verified" && (
                    <CheckCircle2 className="h-4 w-4 shrink-0 fill-success text-primary-foreground" />
                  )}
                </div>
              </div>
              {row.external ? (
                <ExternalLink className="h-5 w-5 shrink-0 text-muted-foreground/50" />
              ) : (
                <ChevronRight className="h-5 w-5 shrink-0 text-muted-foreground/50" />
              )}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
