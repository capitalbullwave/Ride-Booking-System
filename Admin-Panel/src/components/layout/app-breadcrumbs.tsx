"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb";
import { Fragment } from "react";

const routeLabels: Record<string, string> = {
  users: "Users",
  drivers: "Drivers",
  rides: "Rides",
  vehicles: "Vehicles",
  finance: "Finance",
  transactions: "Transactions",
  payouts: "Driver Payouts",
  refunds: "Refund Requests",
  wallet: "Wallet Transactions",
  commission: "Commission Reports",
  coupons: "Coupons",
  support: "Support Center",
  alerts: "Alert Inbox",
  notifications: "Send Notifications",
  profile: "My Profile",
  help: "Help Center",
  reports: "Reports & Analytics",
  settings: "App Settings",
  approval: "Vehicle Approval",
};

export function AppBreadcrumbs() {
  const pathname = usePathname();
  const segments = pathname.split("/").filter(Boolean);

  if (segments.length === 0) {
    return (
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>Dashboard</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>
    );
  }

  return (
    <Breadcrumb>
      <BreadcrumbList>
        <BreadcrumbItem>
          <BreadcrumbLink render={<Link href="/" />}>Dashboard</BreadcrumbLink>
        </BreadcrumbItem>
        {segments.map((segment, index) => {
          const href = `/${segments.slice(0, index + 1).join("/")}`;
          const isLast = index === segments.length - 1;
          const label = routeLabels[segment] ?? (segment.startsWith("USR") || segment.startsWith("DRV") || segment.startsWith("WG") || segment.startsWith("TKT") ? segment : segment);

          return (
            <Fragment key={href}>
              <BreadcrumbSeparator />
              <BreadcrumbItem>
                {isLast ? (
                  <BreadcrumbPage>{label}</BreadcrumbPage>
                ) : (
                  <BreadcrumbLink render={<Link href={href} />}>{label}</BreadcrumbLink>
                )}
              </BreadcrumbItem>
            </Fragment>
          );
        })}
      </BreadcrumbList>
    </Breadcrumb>
  );
}
