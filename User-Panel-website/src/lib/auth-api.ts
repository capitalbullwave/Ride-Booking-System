import { apiFetch, authFetch } from "@/lib/api";
import { normalizePhone } from "@/lib/phone";

export interface LoginRequest {
  dial_code: string;
  phone: string;
  password: string;
  remember: boolean;
}

export interface RegisterRequest {
  dial_code: string;
  phone: string;
  password: string;
  full_name: string;
  email?: string;
}

export interface SignupStartRequest {
  dial_code: string;
  phone: string;
  full_name: string;
  email?: string;
  password: string;
  confirm_password: string;
  terms_agreed: boolean;
}

export interface OtpSendRequest {
  dial_code: string;
  phone: string;
  mode: "login" | "signup";
}

export interface OtpVerifyRequest {
  dial_code: string;
  phone: string;
  otp: string;
  mode: "login" | "signup";
  full_name?: string;
  email?: string;
  password?: string;
}

export interface AuthUser {
  id?: string;
  phone: string;
  name?: string | null;
  email?: string | null;
}

export interface AuthResponse {
  access_token: string;
  refresh_token?: string;
  token_type: string;
  user: AuthUser;
}

interface TokenResponse {
  access_token: string;
  refresh_token: string;
  token_type?: string;
}

interface UserMeResponse {
  id: string;
  email: string;
  phone: string;
  first_name: string;
  last_name: string;
}

function toAuthUser(me: UserMeResponse): AuthUser {
  return {
    id: me.id,
    phone: me.phone,
    name: `${me.first_name} ${me.last_name}`.trim(),
    email: me.email,
  };
}

async function fetchUserProfile(accessToken: string): Promise<AuthUser> {
  const me = await apiFetch<UserMeResponse>(
    "/auth/me",
    { headers: { Authorization: `Bearer ${accessToken}` } },
    "Unable to load profile"
  );
  return toAuthUser(me);
}

async function tokensToAuthResponse(tokens: TokenResponse): Promise<AuthResponse> {
  const user = await fetchUserProfile(tokens.access_token);
  return {
    access_token: tokens.access_token,
    refresh_token: tokens.refresh_token,
    token_type: tokens.token_type ?? "bearer",
    user,
  };
}

export function parseContactPhone(contact: string): { dial_code: string; phone: string } {
  const match = contact.match(/^(\+\d+)\s+(.+)$/);
  if (!match) {
    throw new Error("Invalid phone number format");
  }
  return {
    dial_code: match[1],
    phone: match[2].replace(/\D/g, ""),
  };
}

export async function loginWithPassword(payload: LoginRequest): Promise<AuthResponse> {
  const phone = normalizePhone(payload.dial_code, payload.phone);
  const tokens = await apiFetch<TokenResponse>(
    "/auth/login",
    {
      method: "POST",
      body: JSON.stringify({ phone, password: payload.password, role: "user" }),
    },
    "Unable to sign in. Please try again."
  );
  return tokensToAuthResponse(tokens);
}

export async function registerAccount(payload: RegisterRequest): Promise<AuthResponse> {
  const phone = normalizePhone(payload.dial_code, payload.phone);
  const parts = payload.full_name.trim().split(" ", 2);
  const tokens = await apiFetch<TokenResponse>(
    "/auth/register",
    {
      method: "POST",
      body: JSON.stringify({
        email: payload.email || `${phone.replace("+", "")}@ridebook.app`,
        phone,
        password: payload.password,
        first_name: parts[0] || "User",
        last_name: parts[1] || "",
        role: "user",
      }),
    },
    "Unable to create account. Please try again."
  );
  return tokensToAuthResponse(tokens);
}

export async function sendSignupOtp(
  payload: SignupStartRequest
): Promise<{ message: string; phone: string; dev_otp?: string }> {
  const phone = normalizePhone(payload.dial_code, payload.phone);
  const parts = payload.full_name.trim().split(" ", 2);
  const result = await apiFetch<{ message: string; success: boolean; otp?: string }>(
    "/auth/register/otp/send",
    {
      method: "POST",
      body: JSON.stringify({
        phone,
        password: payload.password,
        first_name: parts[0] || "User",
        last_name: parts[1] || "",
        email: payload.email || undefined,
      }),
    },
    "Unable to send signup OTP. Please try again."
  );
  return {
    message: result.message,
    phone: `${payload.dial_code} ${payload.phone}`,
    ...(result.otp ? { dev_otp: result.otp } : {}),
  };
}

export interface SignupVerifyOtpRequest {
  dial_code: string;
  phone: string;
  otp: string;
}

export async function verifySignupOtp(payload: SignupVerifyOtpRequest): Promise<AuthResponse> {
  const phone = normalizePhone(payload.dial_code, payload.phone);
  const tokens = await apiFetch<TokenResponse>(
    "/auth/register/otp/verify",
    {
      method: "POST",
      body: JSON.stringify({ phone, otp: payload.otp }),
    },
    "Unable to verify OTP. Please try again."
  );
  return tokensToAuthResponse(tokens);
}

export async function sendLoginOtp(
  payload: OtpSendRequest
): Promise<{ message: string; phone: string; dev_otp?: string }> {
  const phone = normalizePhone(payload.dial_code, payload.phone);
  const path =
    payload.mode === "signup"
      ? "/auth/register/otp/resend"
      : "/auth/send-otp";
  const body =
    payload.mode === "signup"
      ? { phone }
      : { role: "user", phone, purpose: "login" as const };
  const result = await apiFetch<{ message: string; success: boolean; otp?: string }>(
    path,
    { method: "POST", body: JSON.stringify(body) },
    payload.mode === "signup"
      ? "Unable to resend signup OTP."
      : "Unable to send OTP. Please try again."
  );
  return {
    message: result.message,
    phone: `${payload.dial_code} ${payload.phone}`,
    ...(result.otp ? { dev_otp: result.otp } : {}),
  };
}

export async function verifyOtp(payload: OtpVerifyRequest): Promise<AuthResponse> {
  const phone = normalizePhone(payload.dial_code, payload.phone);
  const tokens = await apiFetch<TokenResponse>(
    "/auth/verify-otp",
    {
      method: "POST",
      body: JSON.stringify({
        role: "user",
        phone,
        otp: payload.otp,
        purpose: payload.mode === "signup" ? "register" : "login",
      }),
    },
    "Unable to verify OTP. Please try again."
  );
  return tokensToAuthResponse(tokens);
}
