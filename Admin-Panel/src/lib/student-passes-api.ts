import { apiFetch } from "@/lib/api";

export interface StudentPassUser {
  id: string;
  name: string;
  phone: string;
  email?: string;
}

export interface StudentPassItem {
  id: string;
  aadhar_number: string;
  college_name: string;
  aadhar_photo_url?: string | null;
  student_id_photo_url?: string | null;
  status: string;
  discount_percent: number;
  rejection_reason?: string | null;
  verified_at?: string | null;
  created_at?: string | null;
  user?: StudentPassUser;
}

export async function fetchStudentPasses(params?: {
  status?: string;
  search?: string;
  page?: number;
  page_size?: number;
}) {
  const query = new URLSearchParams();
  if (params?.status) query.set("status", params.status);
  if (params?.search) query.set("search", params.search);
  if (params?.page) query.set("page", String(params.page));
  if (params?.page_size) query.set("page_size", String(params.page_size));
  const suffix = query.toString() ? `?${query.toString()}` : "";
  return apiFetch<{ items: StudentPassItem[]; page: number; page_size: number }>(
    `/api/v1/admin/student-passes${suffix}`,
  );
}

export async function approveStudentPass(passId: string) {
  return apiFetch<StudentPassItem>(`/api/v1/admin/student-passes/${passId}/approve`, {
    method: "POST",
  });
}

export async function rejectStudentPass(passId: string, reason: string) {
  return apiFetch<StudentPassItem>(`/api/v1/admin/student-passes/${passId}/reject`, {
    method: "POST",
    body: JSON.stringify({ reason }),
  });
}
