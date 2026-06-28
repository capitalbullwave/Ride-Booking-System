"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import { useTheme } from "next-themes";
import { Mail, Lock, Eye, EyeOff, Moon, Sun, ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/components/providers/auth-provider";
import { DEMO_CREDENTIALS } from "@/lib/auth";
import { APP_NAME, APP_TAGLINE } from "@/constants/routes";
import { toast } from "sonner";

export default function LoginPage() {
  const router = useRouter();
  const { login, isAuthenticated, isLoading } = useAuth();
  const { theme, setTheme } = useTheme();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (!isLoading && isAuthenticated) {
      router.replace("/");
    }
  }, [isAuthenticated, isLoading, router]);

  if (isLoading || isAuthenticated) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
      </div>
    );
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!email.trim() || !password) {
      toast.error("Please enter your email and password");
      return;
    }

    setIsSubmitting(true);
    const result = await login(email, password, rememberMe);
    setIsSubmitting(false);

    if (result.success) {
      toast.success("Welcome back to WaveGo Admin");
      router.replace("/");
      router.refresh();
    } else {
      toast.error(result.error ?? "Login failed");
    }
  };

  const fillDemoCredentials = () => {
    setEmail(DEMO_CREDENTIALS.email);
    setPassword(DEMO_CREDENTIALS.password);
  };

  return (
    <div className="flex min-h-screen bg-background">
      <div className="relative hidden w-1/2 overflow-hidden lg:flex lg:flex-col lg:justify-between">
        <div className="absolute inset-0 bg-[linear-gradient(145deg,#31526E_0%,#4a6d8a_50%,#6086A8_100%)]" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_80%_20%,#D8B39F55,transparent_45%)]" />
        <div className="absolute -right-16 -top-16 h-72 w-72 rounded-full bg-secondary/30 blur-3xl" />
        <div className="absolute -bottom-24 -left-12 h-80 w-80 rounded-full bg-primary/40 blur-3xl" />

        <div className="relative z-10 flex h-full flex-col justify-between p-12 text-white">
          <div className="flex items-center gap-3.5">
            <div className="relative h-12 w-12 overflow-hidden rounded-2xl shadow-lg shadow-black/20">
              <Image src="/logo.svg" alt={APP_NAME} width={48} height={48} className="h-full w-full object-cover" />
            </div>
            <div>
              <p className="font-heading text-xl font-bold">{APP_NAME}</p>
              <p className="text-sm text-white/75">{APP_TAGLINE}</p>
            </div>
          </div>

          <div className="space-y-6">
            <h1 className="font-heading text-4xl font-bold leading-tight xl:text-5xl">
              Your mobility command center
            </h1>
            <p className="max-w-md text-lg text-white/85">
              Monitor rides, ambulance bookings, drivers, and revenue from one refined admin experience.
            </p>
            <div className="grid grid-cols-3 gap-4 pt-2">
              {[
                { label: "Active Rides", value: "892" },
                { label: "Drivers Online", value: "3.2K" },
                { label: "Today's Revenue", value: "₹28L" },
              ].map((stat) => (
                <div
                  key={stat.label}
                  className="rounded-[1.25rem] border border-white/20 bg-white/10 p-4 backdrop-blur-md"
                >
                  <p className="font-heading text-2xl font-bold">{stat.value}</p>
                  <p className="text-xs text-white/75">{stat.label}</p>
                </div>
              ))}
            </div>
          </div>

          <p className="text-sm text-white/55">
            © {new Date().getFullYear()} {APP_NAME}. All rights reserved.
          </p>
        </div>
      </div>

      <div className="relative flex w-full flex-col wavego-mesh lg:w-1/2">
        <div className="absolute right-4 top-4 z-10">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
          >
            <Sun className="h-4 w-4 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
            <Moon className="absolute h-4 w-4 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
            <span className="sr-only">Toggle theme</span>
          </Button>
        </div>

        <div className="flex flex-1 items-center justify-center p-6 sm:p-10">
          <div className="w-full max-w-md space-y-8">
            <div className="flex items-center gap-3 lg:hidden">
              <div className="relative h-10 w-10 overflow-hidden rounded-2xl shadow-md">
                <Image src="/logo.svg" alt={APP_NAME} width={40} height={40} className="h-full w-full object-cover" />
              </div>
              <div>
                <p className="font-heading text-lg font-bold">{APP_NAME}</p>
                <p className="text-xs text-muted-foreground">Admin Panel</p>
              </div>
            </div>

            <Card className="border-border/80 wavego-card-shadow sm:border">
              <CardHeader className="space-y-1 pb-4">
                <CardTitle className="font-heading text-2xl font-bold">Sign in</CardTitle>
                <CardDescription>
                  Enter your credentials to access the admin dashboard
                </CardDescription>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSubmit} className="space-y-5">
                  <div className="space-y-2">
                    <Label htmlFor="email">Email address</Label>
                    <div className="relative">
                      <Mail className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                      <Input
                        id="email"
                        type="email"
                        placeholder="admin@wavego.com"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        className="h-11 pl-9"
                        autoComplete="email"
                        disabled={isSubmitting}
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <Label htmlFor="password">Password</Label>
                      <button
                        type="button"
                        className="text-xs font-medium text-primary hover:underline"
                      >
                        Forgot password?
                      </button>
                    </div>
                    <div className="relative">
                      <Lock className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                      <Input
                        id="password"
                        type={showPassword ? "text" : "password"}
                        placeholder="Enter your password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className="h-11 pl-9 pr-10"
                        autoComplete="current-password"
                        disabled={isSubmitting}
                      />
                      <Button
                        type="button"
                        variant="ghost"
                        size="icon"
                        className="absolute right-1 top-1/2 h-8 w-8 -translate-y-1/2"
                        onClick={() => setShowPassword(!showPassword)}
                      >
                        {showPassword ? (
                          <EyeOff className="h-4 w-4" />
                        ) : (
                          <Eye className="h-4 w-4" />
                        )}
                      </Button>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <Checkbox
                      id="remember"
                      checked={rememberMe}
                      onCheckedChange={(checked) => setRememberMe(!!checked)}
                    />
                    <Label htmlFor="remember" className="font-normal cursor-pointer">
                      Remember me for 24 hours
                    </Label>
                  </div>

                  <Button
                    type="submit"
                    className="h-11 w-full text-base"
                    disabled={isSubmitting}
                  >
                    {isSubmitting ? (
                      "Signing in..."
                    ) : (
                      <>
                        Sign in to Dashboard
                        <ArrowRight className="ml-2 h-4 w-4" />
                      </>
                    )}
                  </Button>
                </form>

                <div className="mt-6 rounded-[1.25rem] border border-dashed border-secondary/50 bg-secondary/10 p-4">
                  <p className="text-xs font-medium text-primary">Demo credentials</p>
                  <p className="mt-1 text-sm text-muted-foreground">
                    Email: <span className="font-mono">{DEMO_CREDENTIALS.email}</span>
                  </p>
                  <p className="text-sm text-muted-foreground">
                    Password: <span className="font-mono">{DEMO_CREDENTIALS.password}</span>
                  </p>
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="mt-3 w-full border-secondary/40"
                    onClick={fillDemoCredentials}
                  >
                    Use demo credentials
                  </Button>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
