import { getApiBaseUrl, getErrorMessage, resolveUserPath } from "@/lib/api";
import {
  clearCompanySession,
  getCompanySession,
  setCompanySession,
} from "@/lib/company-session";

export type CompanyRegisterPayload = {
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
};

export type CompanyRegisterResponse = {
  success: boolean;
  company: {
    id: string;
    company_name: string;
    company_code: string;
    email: string;
    status: string;
  };
};

export type CompanyProfile = {
  id: string;
  company_name: string;
  company_code: string;
  email: string;
  phone: string;
  status: string;
  contact_person: string;
  employee_count?: number;
  total_employees?: number;
};

export type CompanyEmployee = {
  id: string;
  employee_code: string;
  department?: string | null;
  designation?: string | null;
  status: string;
  employee_name?: string | null;
  phone?: string | null;
  email?: string | null;
  ride_count?: number;
  monthly_spend?: number;
};

async function publicCorporateFetch<T>(
  path: string,
  init?: RequestInit,
  fallback = "Request failed",
): Promise<T> {
  const url = `${getApiBaseUrl()}${resolveUserPath(path)}`;
  const response = await fetch(url, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...(init?.headers as Record<string, string> | undefined),
    },
  });
  const text = await response.text();
  let payload: unknown = null;
  try {
    payload = text ? JSON.parse(text) : null;
  } catch {
    payload = text;
  }
  if (!response.ok) {
    throw new Error(getErrorMessage(payload, fallback));
  }
  return payload as T;
}

async function companyAuthFetch<T>(
  path: string,
  init?: RequestInit,
  fallback = "Request failed",
): Promise<T> {
  const session = getCompanySession();
  if (!session?.accessToken) {
    throw new Error("Please login as company admin first");
  }
  const url = `${getApiBaseUrl()}${resolveUserPath(path)}`;
  const response = await fetch(url, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${session.accessToken}`,
      ...(init?.headers as Record<string, string> | undefined),
    },
  });
  const text = await response.text();
  let payload: unknown = null;
  try {
    payload = text ? JSON.parse(text) : null;
  } catch {
    payload = text;
  }
  if (response.status === 401) {
    clearCompanySession();
    throw new Error("Company session expired. Please login again.");
  }
  if (!response.ok) {
    throw new Error(getErrorMessage(payload, fallback));
  }
  return payload as T;
}

export function registerCorporateCompany(payload: CompanyRegisterPayload) {
  return publicCorporateFetch<CompanyRegisterResponse>(
    "/api/v1/corporate/register",
    { method: "POST", body: JSON.stringify(payload) },
    "Unable to register company",
  );
}

export async function loginCorporateCompany(email: string, password: string) {
  const tokens = await publicCorporateFetch<{
    access_token: string;
    refresh_token: string;
  }>(
    "/api/v1/corporate/login",
    { method: "POST", body: JSON.stringify({ email, password }) },
    "Invalid email or password",
  );
  setCompanySession({
    accessToken: tokens.access_token,
    refreshToken: tokens.refresh_token,
    email,
  });
  return tokens;
}

export function fetchCompanyProfile() {
  return companyAuthFetch<CompanyProfile>("/api/v1/corporate/me");
}

export function listMyEmployees(params?: { search?: string }) {
  const q = new URLSearchParams();
  if (params?.search) q.set("search", params.search);
  const qs = q.toString();
  return companyAuthFetch<{ items: CompanyEmployee[]; total: number }>(
    `/api/v1/corporate/me/employees${qs ? `?${qs}` : ""}`,
  );
}

export function addMyEmployee(payload: {
  phone: string;
  employee_code: string;
  department?: string;
  designation?: string;
}) {
  return companyAuthFetch<CompanyEmployee>(
    "/api/v1/corporate/me/employees",
    { method: "POST", body: JSON.stringify(payload) },
    "Unable to add employee",
  );
}

export function setMyEmployeeStatus(
  employeeId: string,
  action: "activate" | "deactivate",
) {
  return companyAuthFetch<CompanyEmployee>(
    `/api/v1/corporate/me/employees/${employeeId}/${action}`,
    { method: "POST" },
  );
}

export function removeMyEmployee(employeeId: string) {
  return companyAuthFetch<{ message: string }>(
    `/api/v1/corporate/me/employees/${employeeId}`,
    { method: "DELETE" },
  );
}
