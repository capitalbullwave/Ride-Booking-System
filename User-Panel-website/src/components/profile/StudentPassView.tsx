"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AppShell, PageHeader } from "@/components/layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ROUTES } from "@/constants/routes";
import {
  fileToUploadDataUrl,
  getStudentPass,
  submitStudentPass,
  type StudentPassApplication,
} from "@/lib/membership-api";

export function StudentPassView() {
  const router = useRouter();
  const [application, setApplication] = useState<StudentPassApplication | null>(null);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [aadharNumber, setAadharNumber] = useState("");
  const [collegeName, setCollegeName] = useState("");
  const [aadharPhoto, setAadharPhoto] = useState<File | null>(null);
  const [studentIdPhoto, setStudentIdPhoto] = useState<File | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    void (async () => {
      try {
        const data = await getStudentPass();
        setApplication(data.application);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    if (aadharNumber.trim().length !== 12) {
      setError("Enter a valid 12-digit Aadhar number");
      return;
    }
    if (collegeName.trim().length < 2) {
      setError("Enter your college name");
      return;
    }
    if (!aadharPhoto || !studentIdPhoto) {
      setError("Upload both Aadhar and student ID photos");
      return;
    }

    setSubmitting(true);
    try {
      const aadharDataUrl = await fileToUploadDataUrl(aadharPhoto);
      const studentIdDataUrl = await fileToUploadDataUrl(studentIdPhoto);
      if (!aadharDataUrl || !studentIdDataUrl) throw new Error("Unable to process images");

      const result = await submitStudentPass({
        aadhar_number: aadharNumber.trim(),
        college_name: collegeName.trim(),
        aadhar_photo: aadharDataUrl,
        student_id_photo: studentIdDataUrl,
      });
      setApplication(result.application);
      router.push(ROUTES.profile);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Submission failed");
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <AppShell>
        <PageHeader title="Student Pass" />
        <div className="flex flex-1 items-center justify-center text-muted-foreground">Loading…</div>
      </AppShell>
    );
  }

  if (application?.status === "approved") {
    return (
      <AppShell>
        <PageHeader title="Student Pass" />
        <div className="px-6 py-10 text-center">
          <h2 className="font-heading text-2xl font-bold">Student pass verified</h2>
          <p className="mt-2 text-muted-foreground">
            You get {application.discount_percent}% off on every ride.
          </p>
        </div>
      </AppShell>
    );
  }

  if (application?.status === "pending") {
    return (
      <AppShell>
        <PageHeader title="Student Pass" />
        <div className="px-6 py-10 text-center">
          <h2 className="font-heading text-2xl font-bold">Verification pending</h2>
          <p className="mt-2 text-muted-foreground">
            Your application for {application.college_name} is under admin review.
          </p>
        </div>
      </AppShell>
    );
  }

  return (
    <AppShell>
      <PageHeader title="Student Pass" />
      <div className="mx-auto w-full max-w-xl px-6 py-6">
        <div className="mb-6 rounded-[24px] bg-gradient-to-br from-secondary to-primary p-5 text-white">
          <h2 className="font-heading text-xl font-bold">Get 20% off every ride</h2>
          <p className="mt-1 text-sm text-white/85">Submit your student details for admin verification.</p>
        </div>

        {application?.status === "rejected" && application.rejection_reason ? (
          <p className="mb-4 rounded-xl border border-destructive/20 bg-destructive/5 p-3 text-sm text-destructive">
            {application.rejection_reason}
          </p>
        ) : null}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <Label htmlFor="aadhar">Aadhar number</Label>
            <Input
              id="aadhar"
              value={aadharNumber}
              onChange={(e) => setAadharNumber(e.target.value.replace(/\D/g, "").slice(0, 12))}
              placeholder="12-digit Aadhar number"
            />
          </div>
          <div>
            <Label htmlFor="college">College name</Label>
            <Input
              id="college"
              value={collegeName}
              onChange={(e) => setCollegeName(e.target.value)}
              placeholder="College or university name"
            />
          </div>
          <div>
            <Label htmlFor="aadharPhoto">Aadhar card photo</Label>
            <Input
              id="aadharPhoto"
              type="file"
              accept="image/*"
              onChange={(e) => setAadharPhoto(e.target.files?.[0] ?? null)}
            />
          </div>
          <div>
            <Label htmlFor="studentIdPhoto">Student ID card photo</Label>
            <Input
              id="studentIdPhoto"
              type="file"
              accept="image/*"
              onChange={(e) => setStudentIdPhoto(e.target.files?.[0] ?? null)}
            />
          </div>
          {error ? <p className="text-sm text-destructive">{error}</p> : null}
          <Button type="submit" className="w-full" disabled={submitting}>
            {submitting ? "Submitting…" : "Submit for verification"}
          </Button>
        </form>
      </div>
    </AppShell>
  );
}
