"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";
import { SettingsHeader } from "@/components/layout";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/constants/routes";
import { getProfile, updateProfile } from "@/lib/profile-api";

export function EmergencyContactView() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    void getProfile()
      .then((profile) => {
        setName(profile.emergency_contact_name ?? "");
        setPhone(profile.emergency_contact_phone ?? "");
      })
      .catch(() => setError("Unable to load profile"))
      .finally(() => setLoading(false));
  }, []);

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    setMessage(null);
    try {
      await updateProfile({
        emergency_contact_name: name.trim(),
        emergency_contact_phone: phone.trim(),
      });
      setMessage("Emergency contact saved");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to save");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="flex min-h-screen flex-col bg-background pb-8">
      <SettingsHeader title="Emergency contact" />
      <div className="w-full flex-1 px-6 py-6 md:px-12 lg:px-24">
        <p className="mb-6 text-sm text-muted-foreground">
          Used for SOS alerts during an active ride — same as the Bull Wave Rides app.
        </p>

        {loading ? (
          <div className="flex justify-center py-12">
            <Loader2 className="h-7 w-7 animate-spin text-primary" />
          </div>
        ) : (
          <div className="mx-auto max-w-lg space-y-4">
            <label className="block">
              <span className="mb-1.5 block text-sm font-semibold text-foreground">
                Contact name
              </span>
              <input
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="h-12 w-full rounded-xl border border-border bg-card px-4 text-sm outline-none focus:border-primary"
                placeholder="Full name"
              />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-sm font-semibold text-foreground">
                Contact phone
              </span>
              <input
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                className="h-12 w-full rounded-xl border border-border bg-card px-4 text-sm outline-none focus:border-primary"
                placeholder="+91 XXXXX XXXXX"
              />
            </label>

            {error ? <p className="text-sm text-destructive">{error}</p> : null}
            {message ? <p className="text-sm text-success">{message}</p> : null}

            <Button
              className="h-12 w-full rounded-2xl"
              disabled={saving}
              onClick={() => void handleSave()}
            >
              {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : "Save contact"}
            </Button>
            <Button
              variant="outline"
              className="h-11 w-full rounded-2xl"
              onClick={() => router.push(ROUTES.profileAccountSettings)}
            >
              Back
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}
