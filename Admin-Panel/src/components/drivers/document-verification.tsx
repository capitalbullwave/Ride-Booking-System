"use client";

import { useMemo, useState } from "react";
import {
  CheckCircle,
  ChevronDown,
  ChevronRight,
  FileText,
  MoreVertical,
  XCircle,
} from "lucide-react";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  approveDriverDocument,
  bulkReviewDriverDocuments,
  DriverDocument,
  fetchDriverDocuments,
  rejectDriverDocument,
} from "@/lib/drivers-api";
import { capitalize, formatDate } from "@/lib/format";
import { Driver } from "@/types";
import { toast } from "sonner";

type SectionId = "license" | "vehicle_rc" | "aadhaar" | "vehicle_docs" | "other";

type SectionMeta = {
  id: SectionId;
  title: string;
  types: string[];
  numberLabel?: string;
};

const SIDE_LABELS: Record<string, string> = {
  driving_license: "Front side",
  driving_license_back: "Back side",
  aadhaar: "Front side",
  aadhaar_back: "Back side",
  aadhar: "Front side",
  aadhar_back: "Back side",
  vehicle_rc: "RC Front",
  vehicle_rc_back: "RC Back",
  insurance: "Vehicle Insurance",
  pollution: "Pollution Certificate",
  permit: "Commercial Permit",
  fitness: "Fitness Certificate",
  vehicle_front: "Vehicle Front Photo",
  vehicle_back: "Vehicle Back Photo",
  vehicle_side: "Vehicle Side Photo",
  pan: "PAN Card",
  profile_photo: "Profile Photo",
};

const LICENSE_TYPES = ["driving_license", "driving_license_back"];
const RC_TYPES = ["vehicle_rc", "vehicle_rc_back"];
const AADHAAR_TYPES = ["aadhaar", "aadhaar_back", "aadhar", "aadhar_back"];
const VEHICLE_DOC_TYPES = [
  "insurance",
  "pollution",
  "permit",
  "fitness",
  "vehicle_front",
  "vehicle_back",
  "vehicle_side",
];

function sectionStatus(docs: DriverDocument[]): string {
  if (docs.length === 0) return "pending";
  if (docs.every((d) => d.status === "approved")) return "approved";
  if (docs.some((d) => d.status === "rejected")) return "rejected";
  return "pending";
}

function docNumber(docs: DriverDocument[], preferredType: string): string | null {
  const preferred = docs.find(
    (d) => d.type === preferredType && d.documentNumber?.trim(),
  );
  if (preferred?.documentNumber) return preferred.documentNumber.trim();
  const any = docs.find((d) => d.documentNumber?.trim());
  return any?.documentNumber?.trim() || null;
}

function buildSections(driver: Driver, documents: DriverDocument[]) {
  const byType = new Map<string, DriverDocument[]>();
  for (const doc of documents) {
    const key = doc.type.toLowerCase();
    const list = byType.get(key) ?? [];
    list.push(doc);
    byType.set(key, list);
  }

  const take = (types: string[]) =>
    types.flatMap((type) => byType.get(type) ?? []);

  const vehicleLabel = capitalize(driver.vehicleType || "bike");
  const sections: Array<
    SectionMeta & {
      documents: DriverDocument[];
      numberValue?: string | null;
      subtitle?: string;
    }
  > = [
    {
      id: "license",
      title: "Driving License",
      types: LICENSE_TYPES,
      numberLabel: "License number",
      numberValue: driver.licenseNumber || docNumber(take(LICENSE_TYPES), "driving_license"),
      documents: take(LICENSE_TYPES),
    },
    {
      id: "vehicle_rc",
      title: "Vehicle Number & RC",
      types: RC_TYPES,
      numberLabel: "Vehicle number",
      numberValue: driver.vehicleNumber || docNumber(take(RC_TYPES), "vehicle_rc"),
      subtitle: `Vehicle type: ${vehicleLabel}`,
      documents: take(RC_TYPES),
    },
    {
      id: "aadhaar",
      title: "Aadhaar Card",
      types: AADHAAR_TYPES,
      numberLabel: "Aadhaar number",
      numberValue: docNumber(take(AADHAAR_TYPES), "aadhaar"),
      documents: take(AADHAAR_TYPES),
    },
    {
      id: "vehicle_docs",
      title: `Vehicle documents (${vehicleLabel})`,
      types: VEHICLE_DOC_TYPES,
      documents: take(VEHICLE_DOC_TYPES),
    },
  ];

  const known = new Set([
    ...LICENSE_TYPES,
    ...RC_TYPES,
    ...AADHAAR_TYPES,
    ...VEHICLE_DOC_TYPES,
  ]);
  const otherDocs = documents.filter((d) => !known.has(d.type.toLowerCase()));
  if (otherDocs.length > 0) {
    sections.push({
      id: "other",
      title: "Other documents",
      types: otherDocs.map((d) => d.type),
      documents: otherDocs,
    });
  }

  // Always show the main registration sections; hide empty catch-all only.
  return sections;
}

type Props = {
  driver: Driver;
  documents: DriverDocument[];
  onDocumentsChange: (documents: DriverDocument[]) => void;
};

export function DocumentVerification({
  driver,
  documents,
  onDocumentsChange,
}: Props) {
  const [openSectionId, setOpenSectionId] = useState<SectionId | null>(null);
  const [rejectOpen, setRejectOpen] = useState(false);
  const [rejectReason, setRejectReason] = useState("");
  const [pendingRejectIds, setPendingRejectIds] = useState<string[]>([]);
  const [pendingRejectTitle, setPendingRejectTitle] = useState("");
  const [isUpdating, setIsUpdating] = useState(false);

  const sections = useMemo(
    () => buildSections(driver, documents),
    [driver, documents],
  );

  const refreshDocuments = async () => {
    const latest = await fetchDriverDocuments(driver.id);
    onDocumentsChange(latest);
  };

  const handleApprove = async (ids: string[], title: string) => {
    if (ids.length === 0) {
      toast.error("No documents to approve in this section");
      return;
    }
    setIsUpdating(true);
    try {
      if (ids.length === 1) {
        await approveDriverDocument(driver.id, ids[0]);
      } else {
        await bulkReviewDriverDocuments(driver.id, ids, "approved");
      }
      await refreshDocuments();
      toast.success(`${title} approved`);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Approve failed");
    } finally {
      setIsUpdating(false);
    }
  };

  const openReject = (ids: string[], title: string) => {
    if (ids.length === 0) {
      toast.error("No documents to reject in this section");
      return;
    }
    setPendingRejectIds(ids);
    setPendingRejectTitle(title);
    setRejectReason("");
    setRejectOpen(true);
  };

  const confirmReject = async () => {
    if (rejectReason.trim().length < 3) {
      toast.error("Enter a rejection reason");
      return;
    }
    setIsUpdating(true);
    try {
      if (pendingRejectIds.length === 1) {
        await rejectDriverDocument(
          driver.id,
          pendingRejectIds[0],
          rejectReason.trim(),
        );
      } else {
        await bulkReviewDriverDocuments(
          driver.id,
          pendingRejectIds,
          "rejected",
          rejectReason.trim(),
        );
      }
      await refreshDocuments();
      toast.success(`${pendingRejectTitle} rejected`);
      setRejectOpen(false);
      setPendingRejectIds([]);
      setRejectReason("");
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Reject failed");
    } finally {
      setIsUpdating(false);
    }
  };

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle>Document Verification</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {sections.map((section) => {
              const isOpen = openSectionId === section.id;
              const hasDocs = section.documents.length > 0;
              const status = hasDocs
                ? sectionStatus(section.documents)
                : "pending";
              const ids = section.documents.map((d) => d.id);

              return (
                <div
                  key={section.id}
                  className="overflow-hidden rounded-xl border border-primary/20"
                >
                  <div
                    className={`flex items-center gap-2 px-4 py-3 ${
                      isOpen
                        ? "bg-primary text-primary-foreground"
                        : hasDocs
                          ? "bg-background"
                          : "bg-muted/40"
                    }`}
                  >
                    <button
                      type="button"
                      className="flex min-w-0 flex-1 items-center gap-3 text-left"
                      onClick={() =>
                        setOpenSectionId(isOpen ? null : section.id)
                      }
                    >
                      {isOpen ? (
                        <ChevronDown className="h-4 w-4 shrink-0" />
                      ) : (
                        <ChevronRight
                          className={`h-4 w-4 shrink-0 ${
                            hasDocs ? "opacity-70" : "opacity-40"
                          }`}
                        />
                      )}
                      <div className="min-w-0">
                        <p
                          className={`truncate font-semibold ${
                            isOpen
                              ? ""
                              : hasDocs
                                ? "text-primary"
                                : "text-primary/50"
                          }`}
                        >
                          {section.title}
                        </p>
                        <p
                          className={`text-xs ${
                            isOpen
                              ? "text-primary-foreground/80"
                              : "text-muted-foreground"
                          }`}
                        >
                          {hasDocs
                            ? `${section.documents.length} item${
                                section.documents.length === 1 ? "" : "s"
                              } · Uploaded ${formatDate(
                                section.documents[0]?.uploadedAt ||
                                  driver.joinedDate,
                              )}`
                            : "Not uploaded yet"}
                        </p>
                      </div>
                    </button>

                    <div className="flex shrink-0 items-center gap-2">
                      {!isOpen && hasDocs ? (
                        <StatusBadge status={status} />
                      ) : null}
                      <DropdownMenu>
                        <DropdownMenuTrigger
                          disabled={isUpdating || !hasDocs}
                          render={
                            <Button
                              variant={isOpen ? "secondary" : "ghost"}
                              size="icon"
                              className="h-8 w-8"
                            />
                          }
                        >
                          <MoreVertical className="h-4 w-4" />
                          <span className="sr-only">Section actions</span>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem
                            onClick={() =>
                              void handleApprove(ids, section.title)
                            }
                          >
                            <CheckCircle className="mr-2 h-4 w-4 text-success" />
                            Approve
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            className="text-destructive focus:text-destructive"
                            onClick={() => openReject(ids, section.title)}
                          >
                            <XCircle className="mr-2 h-4 w-4" />
                            Reject
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </div>
                  </div>

                  {isOpen && (
                    <div className="space-y-4 border-t bg-muted/20 p-4">
                      {!hasDocs ? (
                        <p className="text-sm text-muted-foreground">
                          No documents uploaded in this section yet.
                        </p>
                      ) : (
                        <>
                          <div className="flex items-center justify-between gap-3">
                            <StatusBadge status={status} />
                            {section.subtitle ? (
                              <p className="text-sm text-muted-foreground">
                                {section.subtitle}
                              </p>
                            ) : null}
                          </div>

                          {section.numberLabel ? (
                            <div className="rounded-lg border bg-background p-4">
                              <p className="text-xs text-muted-foreground">
                                {section.numberLabel}
                              </p>
                              <p className="mt-1 font-medium tracking-wide">
                                {section.numberValue || "—"}
                              </p>
                            </div>
                          ) : null}

                          <div className="grid gap-3 sm:grid-cols-2">
                            {section.documents.map((doc) => {
                              const label =
                                SIDE_LABELS[doc.type.toLowerCase()] ||
                                doc.name;
                              return (
                                <div
                                  key={doc.id}
                                  className="rounded-lg border bg-background p-4"
                                >
                                  <div className="flex items-start justify-between gap-2">
                                    <div className="flex items-start gap-3">
                                      <div className="rounded-lg bg-primary/10 p-2">
                                        <FileText className="h-5 w-5 text-primary" />
                                      </div>
                                      <div>
                                        <p className="font-medium">{label}</p>
                                        <p className="text-xs text-muted-foreground">
                                          Uploaded {formatDate(doc.uploadedAt)}
                                        </p>
                                      </div>
                                    </div>
                                    <div className="flex items-center gap-1">
                                      <StatusBadge status={doc.status} />
                                      <DropdownMenu>
                                        <DropdownMenuTrigger
                                          disabled={isUpdating}
                                          render={
                                            <Button
                                              variant="ghost"
                                              size="icon"
                                              className="h-8 w-8"
                                            />
                                          }
                                        >
                                          <MoreVertical className="h-4 w-4" />
                                          <span className="sr-only">
                                            Document actions
                                          </span>
                                        </DropdownMenuTrigger>
                                        <DropdownMenuContent align="end">
                                          <DropdownMenuItem
                                            onClick={() =>
                                              void handleApprove(
                                                [doc.id],
                                                label,
                                              )
                                            }
                                          >
                                            <CheckCircle className="mr-2 h-4 w-4 text-success" />
                                            Approve
                                          </DropdownMenuItem>
                                          <DropdownMenuItem
                                            className="text-destructive focus:text-destructive"
                                            onClick={() =>
                                              openReject([doc.id], label)
                                            }
                                          >
                                            <XCircle className="mr-2 h-4 w-4" />
                                            Reject
                                          </DropdownMenuItem>
                                        </DropdownMenuContent>
                                      </DropdownMenu>
                                    </div>
                                  </div>

                                  {doc.documentNumber &&
                                  !section.numberLabel ? (
                                    <p className="mt-3 text-sm">
                                      <span className="text-muted-foreground">
                                        Number:{" "}
                                      </span>
                                      {doc.documentNumber}
                                    </p>
                                  ) : null}

                                  {doc.rejectionReason ? (
                                    <p className="mt-2 text-xs text-destructive">
                                      Reason: {doc.rejectionReason}
                                    </p>
                                  ) : null}

                                  {doc.url ? (
                                    <div className="mt-3 overflow-hidden rounded-md border bg-muted/30">
                                      {/* eslint-disable-next-line @next/next/no-img-element */}
                                      <img
                                        src={doc.url}
                                        alt={label}
                                        className="max-h-64 w-full object-contain"
                                      />
                                      <a
                                        href={doc.url}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        className="block border-t px-3 py-2 text-xs font-medium text-primary hover:underline"
                                        onClick={(event) => {
                                          event.preventDefault();
                                          window.open(
                                            doc.url,
                                            "_blank",
                                            "noopener,noreferrer",
                                          );
                                        }}
                                      >
                                        Open full size
                                      </a>
                                    </div>
                                  ) : (
                                    <p className="mt-3 text-xs text-muted-foreground">
                                      Document file unavailable
                                    </p>
                                  )}
                                </div>
                              );
                            })}
                          </div>
                        </>
                      )}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      <Dialog open={rejectOpen} onOpenChange={setRejectOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Reject {pendingRejectTitle}</DialogTitle>
          </DialogHeader>
          <div className="space-y-2">
            <Label htmlFor="doc-reject-reason">Reason</Label>
            <Input
              id="doc-reject-reason"
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="Explain why this document was rejected"
            />
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setRejectOpen(false)}
              disabled={isUpdating}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={() => void confirmReject()}
              disabled={isUpdating}
            >
              Reject
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
