import { Suspense } from "react";
import { PhoneLogin } from "@/components/PhoneLogin";
import { LoginView } from "@/components/auth";

function LoginFallback() {
  return (
    <div className="flex h-[100dvh] w-full items-center justify-center overflow-hidden bg-background text-muted-foreground">
      Loading…
    </div>
  );
}

function PhoneLoginGate() {
  return (
    <Suspense fallback={<LoginFallback />}>
      <PhoneLogin />
    </Suspense>
  );
}

function PasswordLoginGate() {
  return (
    <Suspense fallback={<LoginFallback />}>
      <LoginView />
    </Suspense>
  );
}

interface LoginPageProps {
  searchParams: Promise<{ mode?: string }>;
}

export default async function LoginPage({ searchParams }: LoginPageProps) {
  const params = await searchParams;
  const usePassword = params.mode === "password";

  return usePassword ? <PasswordLoginGate /> : <PhoneLoginGate />;
}
