"use client";

import { useCallback, useEffect, useState } from "react";
import { CheckCircle, Eye, RefreshCw, XCircle } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { SearchBar } from "@/components/shared/search-bar";
import { DataTable, Column } from "@/components/shared/data-table";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  approveStudentPass,
  fetchStudentPasses,
  rejectStudentPass,
  type StudentPassItem,
} from "@/lib/student-passes-api";
import { resolveMediaUrl } from "@/lib/api";
import { toast } from "sonner";

export default function StudentPassesPage() {
  const [items, setItems] = useState<StudentPassItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("PENDING");
  const [selected, setSelected] = useState<StudentPassItem | null>(null);
  const [rejectReason, setRejectReason] = useState("");
  const [rejectOpen, setRejectOpen] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await fetchStudentPasses({
        status: status === "all" ? undefined : status,
        search: search || undefined,
      });
      setItems(data.items);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to load student passes");
    } finally {
      setLoading(false);
    }
  }, [search, status]);

  useEffect(() => {
    void load();
  }, [load]);

  const columns: Column<StudentPassItem>[] = [
    {
      key: "user",
      header: "Student",
      cell: (row) => (
        <div>
          <p className="font-medium">{row.user?.name ?? "—"}</p>
          <p className="text-xs text-muted-foreground">{row.user?.phone ?? ""}</p>
        </div>
      ),
    },
    { key: "college_name", header: "College", cell: (row) => row.college_name },
    { key: "aadhar_number", header: "Aadhar", cell: (row) => row.aadhar_number },
    {
      key: "status",
      header: "Status",
      cell: (row) => <StatusBadge status={row.status.toLowerCase()} />,
    },
    {
      key: "actions",
      header: "Actions",
      cell: (row) => (
        <div className="flex gap-2">
          <Button size="sm" variant="outline" onClick={() => setSelected(row)}>
            <Eye className="mr-1 h-4 w-4" />
            Review
          </Button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Student Passes"
        description="Review student applications and verify documents."
      >
        <Button variant="outline" onClick={() => void load()}>
          <RefreshCw className="mr-2 h-4 w-4" />
          Refresh
        </Button>
      </PageHeader>

      <div className="flex flex-col gap-3 sm:flex-row">
        <SearchBar value={search} onChange={setSearch} placeholder="Search student, college, phone..." />
        <Select value={status} onValueChange={(value) => setStatus(value ?? "all")}>
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All</SelectItem>
            <SelectItem value="PENDING">Pending</SelectItem>
            <SelectItem value="APPROVED">Approved</SelectItem>
            <SelectItem value="REJECTED">Rejected</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <DataTable
        columns={columns}
        data={items}
        emptyTitle={loading ? "Loading student passes..." : "No student pass applications found."}
        emptyDescription={
          loading
            ? "Fetching applications from the server."
            : "Try adjusting your search or filters."
        }
      />

      <Dialog open={!!selected} onOpenChange={(open) => !open && setSelected(null)}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>Student Pass Review</DialogTitle>
          </DialogHeader>
          {selected ? (
            <div className="space-y-4">
              <div className="grid gap-2 text-sm">
                <p><strong>Name:</strong> {selected.user?.name}</p>
                <p><strong>Phone:</strong> {selected.user?.phone}</p>
                <p><strong>College:</strong> {selected.college_name}</p>
                <p><strong>Aadhar:</strong> {selected.aadhar_number}</p>
                <p><strong>Status:</strong> {selected.status}</p>
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                {selected.aadhar_photo_url ? (
                  <a href={resolveMediaUrl(selected.aadhar_photo_url) ?? "#"} target="_blank" rel="noreferrer">
                    <img src={resolveMediaUrl(selected.aadhar_photo_url) ?? ""} alt="Aadhar" className="rounded-lg border" />
                  </a>
                ) : null}
                {selected.student_id_photo_url ? (
                  <a href={resolveMediaUrl(selected.student_id_photo_url) ?? "#"} target="_blank" rel="noreferrer">
                    <img src={resolveMediaUrl(selected.student_id_photo_url) ?? ""} alt="Student ID" className="rounded-lg border" />
                  </a>
                ) : null}
              </div>
              {selected.status.toLowerCase() === "pending" ? (
                <DialogFooter className="gap-2 sm:justify-between">
                  <Button
                    variant="outline"
                    onClick={() => {
                      setRejectOpen(true);
                    }}
                  >
                    <XCircle className="mr-2 h-4 w-4" />
                    Reject
                  </Button>
                  <Button
                    onClick={async () => {
                      try {
                        await approveStudentPass(selected.id);
                        toast.success("Student pass approved");
                        setSelected(null);
                        await load();
                      } catch (error) {
                        toast.error(error instanceof Error ? error.message : "Approve failed");
                      }
                    }}
                  >
                    <CheckCircle className="mr-2 h-4 w-4" />
                    Approve
                  </Button>
                </DialogFooter>
              ) : null}
            </div>
          ) : null}
        </DialogContent>
      </Dialog>

      <Dialog open={rejectOpen} onOpenChange={setRejectOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Reject application</DialogTitle>
          </DialogHeader>
          <div className="space-y-2">
            <Label htmlFor="reason">Reason</Label>
            <Input
              id="reason"
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="Explain why the application was rejected"
            />
          </div>
          <DialogFooter>
            <Button
              variant="destructive"
              onClick={async () => {
                if (!selected || rejectReason.trim().length < 3) {
                  toast.error("Enter a rejection reason");
                  return;
                }
                try {
                  await rejectStudentPass(selected.id, rejectReason.trim());
                  toast.success("Application rejected");
                  setRejectOpen(false);
                  setRejectReason("");
                  setSelected(null);
                  await load();
                } catch (error) {
                  toast.error(error instanceof Error ? error.message : "Reject failed");
                }
              }}
            >
              Reject
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
