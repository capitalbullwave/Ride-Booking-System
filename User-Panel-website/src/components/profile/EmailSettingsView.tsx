"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { SettingsHeader } from "@/components/layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ROUTES } from "@/constants/routes";
import { useAuthUser } from "@/hooks/useAuthUser";

export function EmailSettingsView() {
  const router = useRouter();
  const authUser = useAuthUser();
  const [email, setEmail] = useState(
    authUser.email === "Add email" ? "" : authUser.email
  );
  const [error, setError] = useState("");

  const isValidEmail = (value: string) =>
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);

  const handleUpdate = (e: React.FormEvent) => {
    e.preventDefault();

    if (!isValidEmail(email)) {
      setError("Please enter a valid email address");
      return;
    }

    router.push(`${ROUTES.profileEmailVerify}?email=${encodeURIComponent(email)}`);
  };

  return (
    <div className="flex min-h-screen flex-col bg-background pb-8">
      <SettingsHeader />

      <div className="w-full flex-1 px-6 py-6 md:px-12 lg:px-24">
        <div className="max-w-md">
          <h1 className="font-heading text-3xl font-bold text-foreground">Email</h1>
          <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
            You&apos;ll use this email to receive messages, sign in, and recover your account.
          </p>

          <form onSubmit={handleUpdate} className="mt-10">
          <div className="flex flex-col gap-3">
            <Label htmlFor="email" className="text-sm font-semibold text-foreground">
              Email
            </Label>
            <Input
              id="email"
              type="email"
              value={email}
              onChange={(e) => {
                setEmail(e.target.value);
                if (error) setError("");
              }}
              className={`h-12 w-full max-w-full rounded-[14px] border bg-muted px-4 text-base shadow-none focus-visible:bg-card focus-visible:ring-2 ${
                error
                  ? "border-destructive focus-visible:ring-destructive/20"
                  : "border-border focus-visible:ring-primary/20"
              }`}
              placeholder="you@example.com"
              aria-invalid={!!error}
            />
            <p className="text-xs text-muted-foreground">
              A verification code will be sent to this email
            </p>
            {error && <p className="text-xs font-medium text-destructive">{error}</p>}
          </div>

          <Button
            type="submit"
            className="mt-8 h-12 rounded-[14px] px-8 font-semibold"
            disabled={!isValidEmail(email)}
          >
            Update
          </Button>
        </form>
        </div>
      </div>
    </div>
  );
}
