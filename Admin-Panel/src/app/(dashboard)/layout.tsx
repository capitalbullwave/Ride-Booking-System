import { DashboardLayout } from "@/components/layout/dashboard-layout";
import { AuthGuard } from "@/components/layout/auth-guard";

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <AuthGuard>
      <DashboardLayout>{children}</DashboardLayout>
    </AuthGuard>
  );
}
