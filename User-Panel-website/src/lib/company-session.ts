const COMPANY_SESSION_KEY = "wavego_company_session";

export type CompanySession = {
  accessToken: string;
  refreshToken?: string;
  email?: string;
};

export function getCompanySession(): CompanySession | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = sessionStorage.getItem(COMPANY_SESSION_KEY);
    if (!raw) return null;
    return JSON.parse(raw) as CompanySession;
  } catch {
    return null;
  }
}

export function setCompanySession(session: CompanySession) {
  if (typeof window === "undefined") return;
  sessionStorage.setItem(COMPANY_SESSION_KEY, JSON.stringify(session));
}

export function clearCompanySession() {
  if (typeof window === "undefined") return;
  sessionStorage.removeItem(COMPANY_SESSION_KEY);
}
