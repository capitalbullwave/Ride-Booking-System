"use client";

import { useEffect, useMemo, useState } from "react";
import { Save, User } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { ROUTES } from "@/constants/routes";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { appSettings as defaultAppSettings } from "@/data/mock-data";
import {
  getStoredAppSettings,
  storeAppSettings,
  validateAppSettingsWithoutCommission,
} from "@/lib/app-settings";
import type { AppSettings } from "@/types";
import { toast } from "sonner";
import { VehicleCommissionForm } from "@/components/settings/vehicle-commission-form";

function FieldHint({ children }: { children: React.ReactNode }) {
  return <p className="text-xs leading-relaxed text-muted-foreground">{children}</p>;
}

export default function SettingsPage() {
  const [settings, setSettings] = useState<AppSettings>(defaultAppSettings);
  const [savedSettings, setSavedSettings] = useState<AppSettings>(defaultAppSettings);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    const stored = getStoredAppSettings();
    setSettings(stored);
    setSavedSettings(stored);
  }, []);

  const isDirty = useMemo(
    () => JSON.stringify(settings) !== JSON.stringify(savedSettings),
    [settings, savedSettings]
  );

  const updateSetting = <K extends keyof AppSettings>(key: K, value: AppSettings[K]) => {
    setSettings((prev) => ({ ...prev, [key]: value }));
  };

  const handleSave = async () => {
    const validation = validateAppSettingsWithoutCommission(settings);
    if (!validation.valid) {
      toast.error(validation.error ?? "Invalid settings");
      return;
    }

    setIsSaving(true);
    await new Promise((resolve) => setTimeout(resolve, 300));

    storeAppSettings(settings);
    setSavedSettings(settings);
    setIsSaving(false);
    toast.success("App settings saved successfully");
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="App Settings"
        description="Platform-wide Bull Wave Rides configuration — maps, payments, commissions, and integrations. Not your personal account."
      >
        <ButtonLink variant="outline" href={ROUTES.profile}>
          <User className="mr-2 h-4 w-4" />
          My Profile
        </ButtonLink>
        <Button onClick={handleSave} disabled={!isDirty || isSaving}>
          <Save className="mr-2 h-4 w-4" />
          {isSaving ? "Saving..." : "Save Changes"}
        </Button>
      </PageHeader>

      <div className="rounded-[1.25rem] border border-primary/15 bg-primary/5 px-4 py-3 text-sm text-muted-foreground">
        <span className="font-medium text-primary">App Settings</span> controls the entire Bull Wave Rides platform
        (maps, OTP, payments, commissions). To edit your name, email, or password, go to{" "}
        <ButtonLink href={ROUTES.profile} variant="link" className="h-auto p-0 text-primary">
          My Profile
        </ButtonLink>
        .
      </div>

      <Tabs defaultValue="general">
        <TabsList className="flex-wrap">
          <TabsTrigger value="general">General</TabsTrigger>
          <TabsTrigger value="maps">Map Settings</TabsTrigger>
          <TabsTrigger value="otp">OTP Settings</TabsTrigger>
          <TabsTrigger value="payment">Payment</TabsTrigger>
          <TabsTrigger value="commission">Commission</TabsTrigger>
        </TabsList>

        <TabsContent value="general" className="mt-6">
          <Card>
            <CardHeader>
              <CardTitle>Platform Information</CardTitle>
              <CardDescription>
                Public-facing details shown across the Bull Wave Rides rider and driver apps — not your admin login.
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-5 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="app-name">App Name</Label>
                <FieldHint>Brand name users see in the app, emails, and push notifications.</FieldHint>
                <Input
                  id="app-name"
                  value={settings.appName}
                  onChange={(e) => updateSetting("appName", e.target.value)}
                  placeholder="Bull Wave Rides"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="logo-url">Logo URL</Label>
                <FieldHint>Path or URL to the app logo used on login screens and in the app header.</FieldHint>
                <Input
                  id="logo-url"
                  value={settings.logo}
                  onChange={(e) => updateSetting("logo", e.target.value)}
                  placeholder="/logo.svg"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="contact-email">Contact Email</Label>
                <FieldHint>Support email displayed to users for help and ride-related queries.</FieldHint>
                <Input
                  id="contact-email"
                  type="email"
                  value={settings.contactEmail}
                  onChange={(e) => updateSetting("contactEmail", e.target.value)}
                  placeholder="support@wavego.com"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="contact-phone">Contact Phone</Label>
                <FieldHint>Helpline number shown in the app for customer and driver support.</FieldHint>
                <Input
                  id="contact-phone"
                  type="tel"
                  value={settings.contactPhone}
                  onChange={(e) => updateSetting("contactPhone", e.target.value)}
                  placeholder="+91 1800-WAVE-GO"
                />
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="maps" className="mt-6">
          <Card>
            <CardHeader>
              <CardTitle>Map Settings</CardTitle>
              <CardDescription>Google Maps integration for location and routing</CardDescription>
            </CardHeader>
            <CardContent className="space-y-2">
              <Label htmlFor="maps-api-key">Google Maps API Key</Label>
              <FieldHint>
                Used for pickup/drop pins, live ride tracking, route display, and distance or ETA
                calculations in rider and driver apps.
              </FieldHint>
              <Input
                id="maps-api-key"
                type="password"
                value={settings.googleMapsApiKey}
                onChange={(e) => updateSetting("googleMapsApiKey", e.target.value)}
                placeholder="AIza..."
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="otp" className="mt-6">
          <Card>
            <CardHeader>
              <CardTitle>OTP Settings</CardTitle>
              <CardDescription>Firebase configuration for phone OTP login and verification</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="firebase-config">Firebase Configuration (JSON)</Label>
                <FieldHint>
                  When users or drivers sign up or log in with their mobile number, Bull Wave Rides uses Firebase
                  Auth to send and verify OTP. Paste your full Firebase web config here — one setup for the
                  entire platform.
                </FieldHint>
                <Textarea
                  id="firebase-config"
                  rows={10}
                  value={settings.firebaseConfig}
                  onChange={(e) => updateSetting("firebaseConfig", e.target.value)}
                  className="font-mono text-sm"
                  spellCheck={false}
                />
              </div>
              <div className="rounded-[1rem] border border-border/70 bg-muted/30 p-4 text-xs text-muted-foreground">
                <p className="mb-2 font-medium text-foreground">Required JSON fields</p>
                <ul className="list-inside list-disc space-y-1">
                  <li>
                    <span className="font-medium text-foreground">apiKey</span> — connects your app to
                    Firebase
                  </li>
                  <li>
                    <span className="font-medium text-foreground">projectId</span> — your Firebase project
                    (e.g. wavego-prod)
                  </li>
                  <li>
                    <span className="font-medium text-foreground">authDomain</span>,{" "}
                    <span className="font-medium text-foreground">appId</span>, and related fields — needed
                    for production OTP auth
                  </li>
                </ul>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="payment" className="mt-6">
          <Card>
            <CardHeader>
              <CardTitle>Payment Settings</CardTitle>
              <CardDescription>Configure payment gateways for ride bookings</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-5 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="cashfree-app-id">Cashfree App ID</Label>
                <FieldHint>
                  Cashfree Payment Gateway App ID for UPI QR, wallet top-ups, and subscriptions.
                </FieldHint>
                <Input
                  id="cashfree-app-id"
                  type="password"
                  value={settings.cashfreeAppId}
                  onChange={(e) => updateSetting("cashfreeAppId", e.target.value)}
                  placeholder="App ID"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="cashfree-secret">Cashfree Secret Key</Label>
                <FieldHint>
                  Cashfree secret key. Keep this private — never expose it in client apps.
                </FieldHint>
                <Input
                  id="cashfree-secret"
                  type="password"
                  value={settings.cashfreeSecretKey}
                  onChange={(e) => updateSetting("cashfreeSecretKey", e.target.value)}
                  placeholder="cfsk_..."
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="stripe-key">Stripe Secret Key</Label>
                <FieldHint>
                  Optional Stripe secret key for international card payments.
                </FieldHint>
                <Input
                  id="stripe-key"
                  type="password"
                  value={settings.stripeKey}
                  onChange={(e) => updateSetting("stripeKey", e.target.value)}
                  placeholder="sk_live_..."
                />
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="commission" className="mt-6">
          <VehicleCommissionForm />
        </TabsContent>
      </Tabs>
    </div>
  );
}
