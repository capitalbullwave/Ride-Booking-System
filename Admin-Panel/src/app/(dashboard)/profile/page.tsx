"use client";

import { useEffect, useMemo, useState } from "react";
import { Save, Mail, Phone, Shield, KeyRound, Settings, RotateCcw } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { ROUTES } from "@/constants/routes";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { useAuth } from "@/components/providers/auth-provider";
import { DEFAULT_ADMIN_NAME, DEFAULT_ADMIN_PHONE } from "@/lib/auth";
import { toast } from "sonner";

export default function ProfilePage() {
  const { user, updateProfile, updatePassword } = useAuth();

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [isSavingProfile, setIsSavingProfile] = useState(false);
  const [isSavingPassword, setIsSavingPassword] = useState(false);

  const role = user?.role ?? "Super Admin";

  useEffect(() => {
    if (!user) return;
    setName(user.name);
    setEmail(user.email);
    setPhone(user.phone ?? DEFAULT_ADMIN_PHONE);
  }, [user]);

  const savedProfile = useMemo(
    () => ({
      name: user?.name ?? "",
      email: user?.email ?? "",
      phone: user?.phone ?? DEFAULT_ADMIN_PHONE,
    }),
    [user]
  );

  const profileDirty =
    name.trim() !== savedProfile.name ||
    email.trim().toLowerCase() !== savedProfile.email ||
    phone.trim() !== savedProfile.phone;

  const passwordDirty =
    currentPassword.length > 0 || newPassword.length > 0 || confirmPassword.length > 0;

  const initials = (name || DEFAULT_ADMIN_NAME)
    .split(" ")
    .map((n) => n[0])
    .join("")
    .slice(0, 2);

  const resetProfileForm = () => {
    setName(savedProfile.name);
    setEmail(savedProfile.email);
    setPhone(savedProfile.phone);
  };

  const handleSaveProfile = async () => {
    setIsSavingProfile(true);
    await new Promise((resolve) => setTimeout(resolve, 300));

    const result = updateProfile({ name, email, phone });
    setIsSavingProfile(false);

    if (result.success) {
      toast.success("Profile updated successfully");
    } else {
      toast.error(result.error ?? "Failed to update profile");
    }
  };

  const handleUpdatePassword = async () => {
    if (newPassword !== confirmPassword) {
      toast.error("New passwords do not match");
      return;
    }

    setIsSavingPassword(true);
    await new Promise((resolve) => setTimeout(resolve, 300));

    const result = updatePassword(currentPassword, newPassword);
    setIsSavingPassword(false);

    if (result.success) {
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
      toast.success("Password updated successfully");
    } else {
      toast.error(result.error ?? "Failed to update password");
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="My Profile"
        description="Your personal admin account — name, email, phone, and password. Not platform settings."
      >
        <ButtonLink variant="outline" href={ROUTES.settings}>
          <Settings className="mr-2 h-4 w-4" />
          App Settings
        </ButtonLink>
        <Button onClick={handleSaveProfile} disabled={!profileDirty || isSavingProfile}>
          <Save className="mr-2 h-4 w-4" />
          {isSavingProfile ? "Saving..." : "Save Changes"}
        </Button>
      </PageHeader>

      <div className="rounded-[1.25rem] border border-secondary/30 bg-secondary/10 px-4 py-3 text-sm text-muted-foreground">
        <span className="font-medium text-foreground">My Profile</span> is only for your admin login account.
        To change app name, payment keys, or commissions, go to{" "}
        <ButtonLink href={ROUTES.settings} variant="link" className="h-auto p-0 text-primary">
          App Settings
        </ButtonLink>
        .
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <Card className="lg:col-span-1">
          <CardContent className="flex flex-col items-center p-8 text-center">
            <Avatar className="h-24 w-24">
              <AvatarFallback className="bg-primary text-3xl text-primary-foreground">
                {initials}
              </AvatarFallback>
            </Avatar>
            <h2 className="mt-4 font-heading text-xl font-bold">{name || DEFAULT_ADMIN_NAME}</h2>
            <p className="text-sm text-muted-foreground">{email || "admin@wavego.com"}</p>
            <p className="mt-1 text-sm text-muted-foreground">{phone}</p>
            <div className="mt-3 inline-flex items-center gap-2 rounded-full bg-primary/10 px-3 py-1 text-xs font-medium text-primary">
              <Shield className="h-3.5 w-3.5" />
              {role}
            </div>
          </CardContent>
        </Card>

        <div className="space-y-6 lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle>Personal Information</CardTitle>
              <CardDescription>Update your name and contact details</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2 sm:col-span-2">
                <Label htmlFor="profile-name">Full Name</Label>
                <Input
                  id="profile-name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Enter your full name"
                  autoComplete="name"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="profile-email">Email</Label>
                <div className="relative">
                  <Mail className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    id="profile-email"
                    className="pl-9"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="you@wavego.com"
                    autoComplete="email"
                  />
                </div>
              </div>
              <div className="space-y-2">
                <Label htmlFor="profile-phone">Phone</Label>
                <div className="relative">
                  <Phone className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    id="profile-phone"
                    className="pl-9"
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="+91 98765 00000"
                    autoComplete="tel"
                  />
                </div>
              </div>
            </CardContent>
            <CardFooter className="flex flex-wrap gap-2 border-t border-border/60 bg-muted/20">
              <Button
                onClick={handleSaveProfile}
                disabled={!profileDirty || isSavingProfile}
              >
                <Save className="mr-2 h-4 w-4" />
                {isSavingProfile ? "Saving..." : "Save Profile"}
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={resetProfileForm}
                disabled={!profileDirty || isSavingProfile}
              >
                <RotateCcw className="mr-2 h-4 w-4" />
                Reset
              </Button>
            </CardFooter>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Security</CardTitle>
              <CardDescription>Password and account security settings</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="profile-current-password">Current Password</Label>
                <div className="relative">
                  <KeyRound className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    id="profile-current-password"
                    className="pl-9"
                    type="password"
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    placeholder="Enter current password"
                    autoComplete="current-password"
                  />
                </div>
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="profile-new-password">New Password</Label>
                  <div className="relative">
                    <KeyRound className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                    <Input
                      id="profile-new-password"
                      className="pl-9"
                      type="password"
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      placeholder="At least 6 characters"
                      autoComplete="new-password"
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="profile-confirm-password">Confirm Password</Label>
                  <div className="relative">
                    <KeyRound className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                    <Input
                      id="profile-confirm-password"
                      className="pl-9"
                      type="password"
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      placeholder="Re-enter new password"
                      autoComplete="new-password"
                    />
                  </div>
                </div>
              </div>
            </CardContent>
            <CardFooter className="flex flex-wrap gap-2 border-t border-border/60 bg-muted/20">
              <Button
                onClick={handleUpdatePassword}
                disabled={
                  !passwordDirty ||
                  isSavingPassword ||
                  !currentPassword ||
                  !newPassword ||
                  !confirmPassword
                }
              >
                <KeyRound className="mr-2 h-4 w-4" />
                {isSavingPassword ? "Updating..." : "Update Password"}
              </Button>
            </CardFooter>
          </Card>
        </div>
      </div>
    </div>
  );
}
