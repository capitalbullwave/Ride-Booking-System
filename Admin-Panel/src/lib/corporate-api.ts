import { apiFetch } from "@/lib/api";

export type CompanyStatus = "PENDING" | "APPROVED" | "REJECTED" | "SUSPENDED";

export interface CorporateCompany {
  id: string;
  company_name: string;
  company_code: string;
  gst_number?: string | null;
  pan_number?: string | null;
  website?: string | null;
  industry?: string | null;
  company_size?: string | null;
  address?: string | null;
  city?: string | null;
  state?: string | null;
  country: string;
  contact_person: string;
  email: string;
  phone: string;
  credit_limit: number;
  wallet_balance: number;
  status: CompanyStatus;
  rejection_reason?: string | null;
  approved_at?: string | null;
  created_at: string;
  updated_at: string;
  employee_count?: number;
  today_rides?: number;
  monthly_spend?: number;
  outstanding_amount?: number;
  current_month_spend?: number;
  total_employees?: number;
  total_rides?: number;
}

export interface CorporateEmployee {
  id: string;
  company_id: string;
  user_id: string;
  employee_code: string;
  department?: string | null;
  designation?: string | null;
  ride_limit?: number | null;
  status: string;
  joined_at: string;
  employee_name?: string | null;
  phone?: string | null;
  email?: string | null;
  ride_count?: number;
  monthly_spend?: number;
}

export interface CorporatePolicy {
  id: string;
  company_id: string;
  allowed_vehicle_types?: string[] | null;
  max_ride_amount?: number | null;
  office_start_time?: string | null;
  office_end_time?: string | null;
  working_days?: number[] | null;
  approval_required: boolean;
  purpose_required: boolean;
}

export interface CorporateRide {
  id: string;
  public_id: string;
  company_id?: string | null;
  company_name?: string | null;
  employee_id?: string | null;
  employee_name?: string | null;
  employee_code?: string | null;
  status: string;
  ride_type: string;
  payment_source: string;
  estimated_fare: number;
  final_fare?: number | null;
  pickup_address: string;
  dropoff_address: string;
  created_at: string;
  completed_at?: string | null;
}

export interface CorporateDashboard {
  total_companies: number;
  pending_companies: number;
  approved_companies: number;
  active_employees: number;
  today_corporate_rides: number;
  monthly_corporate_revenue: number;
  pending_approvals: CorporateCompany[];
  ride_trend: { day: string; count: number }[];
  top_companies: {
    company_id: string;
    company_name: string;
    ride_count: number;
    spend: number;
  }[];
  monthly_ride_count: { month: string; count: number }[];
  monthly_spending: { month: string; amount: number }[];
}

export interface Paginated<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
}

export function registerCorporateCompany(payload: {
  company_name: string;
  gst_number?: string;
  pan_number?: string;
  website?: string;
  industry?: string;
  company_size?: string;
  address?: string;
  city?: string;
  state?: string;
  country?: string;
  contact_person: string;
  email: string;
  phone: string;
  password: string;
}) {
  return apiFetch<{ success: boolean; company: CorporateCompany }>(
    "/api/v1/corporate/register",
    { method: "POST", body: JSON.stringify(payload) },
  );
}

export function fetchCorporateDashboard() {
  return apiFetch<CorporateDashboard>("/api/v1/admin/corporate/dashboard");
}

export function listCorporateCompanies(params?: {
  status?: string;
  search?: string;
  page?: number;
  limit?: number;
}) {
  const q = new URLSearchParams();
  if (params?.status) q.set("status", params.status);
  if (params?.search) q.set("search", params.search);
  if (params?.page) q.set("page", String(params.page));
  if (params?.limit) q.set("limit", String(params.limit));
  const qs = q.toString();
  return apiFetch<Paginated<CorporateCompany>>(
    `/api/v1/admin/corporate/companies${qs ? `?${qs}` : ""}`,
  );
}

export function getCorporateCompany(id: string) {
  return apiFetch<CorporateCompany>(`/api/v1/admin/corporate/companies/${id}`);
}

export function updateCorporateCompany(
  id: string,
  payload: Partial<CorporateCompany> & { credit_limit?: number },
) {
  return apiFetch<CorporateCompany>(`/api/v1/admin/corporate/companies/${id}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}

export function approveCorporateCompany(id: string) {
  return apiFetch<CorporateCompany>(
    `/api/v1/admin/corporate/companies/${id}/approve`,
    { method: "POST" },
  );
}

export function rejectCorporateCompany(id: string, reason?: string) {
  return apiFetch<CorporateCompany>(
    `/api/v1/admin/corporate/companies/${id}/reject`,
    { method: "POST", body: JSON.stringify({ reason }) },
  );
}

export function suspendCorporateCompany(id: string) {
  return apiFetch<CorporateCompany>(
    `/api/v1/admin/corporate/companies/${id}/suspend`,
    { method: "POST" },
  );
}

export function deleteCorporateCompany(id: string) {
  return apiFetch<{ message: string }>(
    `/api/v1/admin/corporate/companies/${id}`,
    { method: "DELETE" },
  );
}

export function listCorporateEmployees(
  companyId: string,
  params?: { status?: string; search?: string; page?: number; limit?: number },
) {
  const q = new URLSearchParams();
  if (params?.status) q.set("status", params.status);
  if (params?.search) q.set("search", params.search);
  if (params?.page) q.set("page", String(params.page));
  if (params?.limit) q.set("limit", String(params.limit));
  const qs = q.toString();
  return apiFetch<Paginated<CorporateEmployee>>(
    `/api/v1/admin/corporate/companies/${companyId}/employees${qs ? `?${qs}` : ""}`,
  );
}

export function addCorporateEmployee(
  companyId: string,
  payload: {
    phone?: string;
    email?: string;
    user_id?: string;
    employee_code: string;
    department?: string;
    designation?: string;
    ride_limit?: number;
  },
) {
  return apiFetch<CorporateEmployee>(
    `/api/v1/admin/corporate/companies/${companyId}/employees`,
    { method: "POST", body: JSON.stringify(payload) },
  );
}

export function setEmployeeStatus(
  companyId: string,
  employeeId: string,
  action: "activate" | "deactivate",
) {
  return apiFetch<CorporateEmployee>(
    `/api/v1/admin/corporate/companies/${companyId}/employees/${employeeId}/${action}`,
    { method: "POST" },
  );
}

export function removeCorporateEmployee(companyId: string, employeeId: string) {
  return apiFetch<{ message: string }>(
    `/api/v1/admin/corporate/companies/${companyId}/employees/${employeeId}`,
    { method: "DELETE" },
  );
}

export function getCorporatePolicy(companyId: string) {
  return apiFetch<CorporatePolicy>(
    `/api/v1/admin/corporate/companies/${companyId}/policy`,
  );
}

export function upsertCorporatePolicy(
  companyId: string,
  payload: Partial<CorporatePolicy>,
) {
  return apiFetch<CorporatePolicy>(
    `/api/v1/admin/corporate/companies/${companyId}/policy`,
    { method: "PUT", body: JSON.stringify(payload) },
  );
}

export function listCorporatePolicies(params?: { page?: number; limit?: number }) {
  const q = new URLSearchParams();
  if (params?.page) q.set("page", String(params.page));
  if (params?.limit) q.set("limit", String(params.limit));
  const qs = q.toString();
  return apiFetch<{
    items: { company: CorporateCompany; policy: CorporatePolicy | null }[];
    total: number;
  }>(`/api/v1/admin/corporate/policies${qs ? `?${qs}` : ""}`);
}

export function listCorporateRides(params?: {
  company_id?: string;
  employee_id?: string;
  status?: string;
  page?: number;
  limit?: number;
}) {
  const q = new URLSearchParams();
  if (params?.company_id) q.set("company_id", params.company_id);
  if (params?.employee_id) q.set("employee_id", params.employee_id);
  if (params?.status) q.set("status", params.status);
  if (params?.page) q.set("page", String(params.page));
  if (params?.limit) q.set("limit", String(params.limit));
  const qs = q.toString();
  return apiFetch<Paginated<CorporateRide>>(
    `/api/v1/admin/corporate/rides${qs ? `?${qs}` : ""}`,
  );
}

export function fetchCorporateReports(params?: {
  company_id?: string;
  employee_id?: string;
  from_date?: string;
  to_date?: string;
}) {
  const q = new URLSearchParams();
  if (params?.company_id) q.set("company_id", params.company_id);
  if (params?.employee_id) q.set("employee_id", params.employee_id);
  if (params?.from_date) q.set("from_date", params.from_date);
  if (params?.to_date) q.set("to_date", params.to_date);
  const qs = q.toString();
  return apiFetch<{
    ride_count: number;
    completed_rides: number;
    cancelled_rides: number;
    monthly_spending: number;
  }>(`/api/v1/admin/corporate/reports${qs ? `?${qs}` : ""}`);
}
