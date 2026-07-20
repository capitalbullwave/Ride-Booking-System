import { apiFetch, resolveMediaUrl } from "@/lib/api";

export interface SelfieVerificationLog {
  id: string;
  driverId: string;
  driverName?: string;
  driverPhone?: string;
  shiftId?: string | null;
  status: string;
  matched: boolean;
  confidenceScore?: number | null;
  livenessPassed: boolean;
  livenessDetails?: Record<string, unknown> | null;
  faceProvider?: string | null;
  livenessProvider?: string | null;
  selfieImagePath?: string | null;
  selfieImageDataUrl?: string | null;
  errorCode?: string | null;
  errorMessage?: string | null;
  attemptNumber: number;
  source: string;
  createdAt?: string | null;
}

export interface DriverShiftRecord {
  id: string;
  driverId: string;
  startedAt?: string | null;
  endedAt?: string | null;
  status: string;
  selfieVerified: boolean;
  selfieVerifiedAt?: string | null;
  forceCloseReason?: string | null;
  verificationLogId?: string | null;
}

export interface OnlineVerifiedDriver {
  id: string;
  name: string;
  phone: string;
  status: string;
  shift: DriverShiftRecord;
}

export async function fetchSelfieVerifications(params?: {
  driverId?: string;
  status?: string;
  page?: number;
  limit?: number;
}): Promise<{
  items: SelfieVerificationLog[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}> {
  const query = new URLSearchParams();
  if (params?.driverId) query.set("driver_id", params.driverId);
  if (params?.status) query.set("status", params.status);
  if (params?.page) query.set("page", String(params.page));
  if (params?.limit) query.set("limit", String(params.limit));
  const qs = query.toString();
  return apiFetch(`/api/v1/admin/selfie-verifications${qs ? `?${qs}` : ""}`);
}

export async function fetchSelfieVerification(
  logId: string,
): Promise<SelfieVerificationLog> {
  const log = await apiFetch<SelfieVerificationLog>(
    `/api/v1/admin/selfie-verifications/${logId}`,
  );
  return {
    ...log,
    selfieImageDataUrl:
      log.selfieImageDataUrl ??
      (log.selfieImagePath ? resolveMediaUrl(log.selfieImagePath) : null),
  };
}

export async function deleteSelfieVerification(
  logId: string,
): Promise<{ ok: boolean; id: string }> {
  return apiFetch(`/api/v1/admin/selfie-verifications/${logId}`, {
    method: "DELETE",
  });
}

export async function fetchDriverShifts(
  driverId: string,
  params?: { page?: number; limit?: number },
): Promise<{ items: DriverShiftRecord[]; total: number }> {
  const query = new URLSearchParams();
  if (params?.page) query.set("page", String(params.page));
  if (params?.limit) query.set("limit", String(params.limit));
  const qs = query.toString();
  return apiFetch(
    `/api/v1/admin/drivers/${driverId}/shifts${qs ? `?${qs}` : ""}`,
  );
}

export async function fetchOnlineVerifiedDrivers(): Promise<OnlineVerifiedDriver[]> {
  const data = await apiFetch<{ items: OnlineVerifiedDriver[] }>(
    "/api/v1/admin/online-drivers/verified",
  );
  return data.items ?? [];
}

export async function forceOfflineDriver(
  driverId: string,
  reason = "Forced offline by admin",
): Promise<{ driver_id: string; status: string; message: string }> {
  return apiFetch(`/api/v1/admin/drivers/${driverId}/force-offline`, {
    method: "POST",
    body: JSON.stringify({ reason }),
  });
}
