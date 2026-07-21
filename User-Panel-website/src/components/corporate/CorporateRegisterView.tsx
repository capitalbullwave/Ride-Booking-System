"use client";

import { FormEvent, useState } from "react";
import Link from "next/link";
import { Building2, CheckCircle2, Loader2 } from "lucide-react";
import { LandingHeader } from "@/components/landing/LandingHeader";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ROUTES } from "@/constants/routes";
import {
  registerCorporateCompany,
  type CompanyRegisterPayload,
} from "@/lib/corporate-api";
import { cn } from "@/lib/utils";

const inputClass =
  "h-11 rounded-xl border-border bg-background text-foreground placeholder:text-muted-foreground/60 focus-visible:border-primary focus-visible:ring-2 focus-visible:ring-primary/15";

const emptyForm: CompanyRegisterPayload = {
  company_name: "",
  gst_number: "",
  pan_number: "",
  website: "",
  industry: "",
  company_size: "",
  address: "",
  city: "",
  state: "",
  country: "India",
  contact_person: "",
  email: "",
  phone: "",
  password: "",
};

export function CorporateRegisterView() {
  const [form, setForm] = useState<CompanyRegisterPayload>(emptyForm);
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState<{
    company_name: string;
    company_code: string;
    email: string;
  } | null>(null);

  const setField = (key: keyof CompanyRegisterPayload, value: string) => {
    setForm((prev) => ({ ...prev, [key]: value }));
  };

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError("");

    if (!form.company_name.trim() || !form.contact_person.trim()) {
      setError("Company name and contact person are required.");
      return;
    }
    if (!form.email.trim() || !form.phone.trim()) {
      setError("Email and phone are required.");
      return;
    }
    if (form.password.length < 8) {
      setError("Password must be at least 8 characters.");
      return;
    }
    if (form.password !== confirmPassword) {
      setError("Passwords do not match.");
      return;
    }

    setSubmitting(true);
    try {
      const payload: CompanyRegisterPayload = {
        ...form,
        company_name: form.company_name.trim(),
        contact_person: form.contact_person.trim(),
        email: form.email.trim().toLowerCase(),
        phone: form.phone.trim(),
        gst_number: form.gst_number?.trim() || undefined,
        pan_number: form.pan_number?.trim() || undefined,
        website: form.website?.trim() || undefined,
        industry: form.industry?.trim() || undefined,
        company_size: form.company_size?.trim() || undefined,
        address: form.address?.trim() || undefined,
        city: form.city?.trim() || undefined,
        state: form.state?.trim() || undefined,
        country: form.country?.trim() || "India",
      };
      const res = await registerCorporateCompany(payload);
      setResult({
        company_name: res.company.company_name,
        company_code: res.company.company_code,
        email: res.company.email,
      });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Registration failed");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-[100dvh] bg-background">
      <LandingHeader />
      <main className="mx-auto max-w-3xl px-6 py-10 md:py-14">
        <div className="mb-8 flex items-start gap-4">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-primary/10 text-primary">
            <Building2 className="h-6 w-6" />
          </div>
          <div>
            <h1 className="font-heading text-3xl font-bold tracking-tight text-foreground">
              Register your company
            </h1>
            <p className="mt-2 text-sm text-muted-foreground md:text-base">
              Create a Bull Wave Rides for Business account. After approval, your
              employees can book rides billed to the company.
            </p>
          </div>
        </div>

        {result ? (
          <div className="rounded-2xl border border-border bg-card p-6 shadow-sm">
            <div className="flex items-center gap-3 text-primary">
              <CheckCircle2 className="h-6 w-6" />
              <h2 className="text-xl font-semibold">Application submitted</h2>
            </div>
            <p className="mt-3 text-sm text-muted-foreground">
              Your company registration is pending admin approval. You will be
              able to manage employees after approval.
            </p>
            <dl className="mt-6 space-y-2 text-sm">
              <div className="flex justify-between gap-4">
                <dt className="text-muted-foreground">Company</dt>
                <dd className="font-medium">{result.company_name}</dd>
              </div>
              <div className="flex justify-between gap-4">
                <dt className="text-muted-foreground">Company code</dt>
                <dd className="font-medium">{result.company_code}</dd>
              </div>
              <div className="flex justify-between gap-4">
                <dt className="text-muted-foreground">Login email</dt>
                <dd className="font-medium">{result.email}</dd>
              </div>
              <div className="flex justify-between gap-4">
                <dt className="text-muted-foreground">Status</dt>
                <dd className="font-medium">PENDING</dd>
              </div>
            </dl>
            <div className="mt-6 flex flex-wrap gap-3">
              <Button
                nativeButton={false}
                render={<Link href={ROUTES.corporateLogin} />}
              >
                Company login
              </Button>
              <Button nativeButton={false} render={<Link href={ROUTES.landing} />}>
                Back to home
              </Button>
            </div>
          </div>
        ) : (
          <form
            onSubmit={onSubmit}
            className="space-y-6 rounded-2xl border border-border bg-card p-6 shadow-sm"
          >
            <section className="grid gap-4 sm:grid-cols-2">
              <Field label="Company name *" className="sm:col-span-2">
                <Input
                  className={inputClass}
                  value={form.company_name}
                  onChange={(e) => setField("company_name", e.target.value)}
                  required
                />
              </Field>
              <Field label="GST number">
                <Input
                  className={inputClass}
                  value={form.gst_number}
                  onChange={(e) => setField("gst_number", e.target.value)}
                  placeholder="15 characters"
                />
              </Field>
              <Field label="PAN number">
                <Input
                  className={inputClass}
                  value={form.pan_number}
                  onChange={(e) => setField("pan_number", e.target.value)}
                  placeholder="10 characters"
                />
              </Field>
              <Field label="Website">
                <Input
                  className={inputClass}
                  value={form.website}
                  onChange={(e) => setField("website", e.target.value)}
                />
              </Field>
              <Field label="Industry">
                <Input
                  className={inputClass}
                  value={form.industry}
                  onChange={(e) => setField("industry", e.target.value)}
                />
              </Field>
              <Field label="Company size">
                <Input
                  className={inputClass}
                  value={form.company_size}
                  onChange={(e) => setField("company_size", e.target.value)}
                  placeholder="e.g. 50-200"
                />
              </Field>
              <Field label="Country">
                <Input
                  className={inputClass}
                  value={form.country}
                  onChange={(e) => setField("country", e.target.value)}
                />
              </Field>
              <Field label="Address" className="sm:col-span-2">
                <Input
                  className={inputClass}
                  value={form.address}
                  onChange={(e) => setField("address", e.target.value)}
                />
              </Field>
              <Field label="City">
                <Input
                  className={inputClass}
                  value={form.city}
                  onChange={(e) => setField("city", e.target.value)}
                />
              </Field>
              <Field label="State">
                <Input
                  className={inputClass}
                  value={form.state}
                  onChange={(e) => setField("state", e.target.value)}
                />
              </Field>
            </section>

            <section className="grid gap-4 border-t border-border pt-6 sm:grid-cols-2">
              <h2 className="sm:col-span-2 text-sm font-semibold uppercase tracking-wide text-muted-foreground">
                Contact & login
              </h2>
              <Field label="Contact person *" className="sm:col-span-2">
                <Input
                  className={inputClass}
                  value={form.contact_person}
                  onChange={(e) => setField("contact_person", e.target.value)}
                  required
                />
              </Field>
              <Field label="Email *">
                <Input
                  type="email"
                  className={inputClass}
                  value={form.email}
                  onChange={(e) => setField("email", e.target.value)}
                  required
                />
              </Field>
              <Field label="Phone *">
                <Input
                  className={inputClass}
                  value={form.phone}
                  onChange={(e) => setField("phone", e.target.value)}
                  required
                />
              </Field>
              <Field label="Password *">
                <Input
                  type="password"
                  className={inputClass}
                  value={form.password}
                  onChange={(e) => setField("password", e.target.value)}
                  required
                  minLength={8}
                />
              </Field>
              <Field label="Confirm password *">
                <Input
                  type="password"
                  className={inputClass}
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  required
                  minLength={8}
                />
              </Field>
            </section>

            {error && (
              <p className="rounded-xl bg-destructive/10 px-3 py-2 text-sm text-destructive">
                {error}
              </p>
            )}

            <Button type="submit" className="w-full sm:w-auto" disabled={submitting}>
              {submitting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Submitting…
                </>
              ) : (
                "Submit for approval"
              )}
            </Button>
            <p className="mt-6 text-center text-sm text-muted-foreground">
              Already registered?{" "}
              <Link href={ROUTES.corporateLogin} className="font-medium text-primary">
                Company login
              </Link>
            </p>
          </form>
        )}
      </main>
    </div>
  );
}

function Field({
  label,
  children,
  className,
}: {
  label: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("space-y-2", className)}>
      <Label className="text-sm text-foreground">{label}</Label>
      {children}
    </div>
  );
}
