## WaveGo1 — Project Status (Auth + Design 02)

This file documents **exactly what has been implemented/changed** in this workspace so far, especially around **Auth (Login / Signup / OTP)** and the **Design 02** layout.

---

## Tech stack

- **Framework**: Next.js (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind (theme tokens via `bg-background`, `text-primary`, etc.)
- **Animation**: Framer Motion

---

## Brand / design tokens (WaveGo)

- **Source of truth**: `src/constants/brand.ts`
- **Design rule doc**: `.cursor/rules/wavego-design.mdc`

Key palette:
- Primary: `#31526E`
- Secondary: `#D8B39F`
- Background: `#FAF8F4`
- Foreground: `#20242C`
- Muted: `#E8E4DD`
- Muted-foreground: `#6086A8`

---

## Main auth routes (App Router)

Routes live in `src/constants/routes.ts`.

- **Login**: `src/app/login/page.tsx` → renders `src/components/auth/LoginView.tsx`
- **Signup**: `src/app/signup/page.tsx` → renders `src/components/auth/SignupView.tsx`
- **OTP**: `src/app/otp/page.tsx` → renders `src/components/auth/OTPView.tsx`
- **Create profile (redirect)**: `src/app/create-profile/page.tsx` (redirects to `/signup`)

All three pages use a `Suspense` wrapper so `useSearchParams()` is safe.

---

## Auth “session” implementation (demo)

Auth session is a **demo client-side session** stored in `sessionStorage` + a cookie flag.

Implementation: `src/lib/auth-session.ts`

- **Cookie**: `wavego-auth` set to `"1"` for 1 day when authenticated
- **Session storage key**: `wavego-auth-session`
- **OTP pending phone key**: `wavego-pending-otp-phone`
- **Post-login redirect key**: `wavego-post-login-redirect`

Constants: `src/constants/auth.ts`

---

## Middleware protection

File: `middleware.ts`

- Public routes include: `/`, `/login`, `/signup`, `/create-profile`, `/otp`, `/legal/*`, `/safety`
- Any non-public route without cookie `wavego-auth=1` redirects to `/login?redirect=<pathname>`
- If authenticated, visiting `/login` or `/signup` redirects to `/home`

---

## Login (Design 02)

File: `src/components/auth/LoginView.tsx`

### Layout (Design 02)
- Full-page background `bg-background`
- **Left (desktop)**: services panel
- **Right**: white rounded login card
- **Mobile**: services panel appears below the card
- Body scroll disabled on auth pages (`document.body.style.overflow = "hidden"`)

### Login method: Phone + Password (demo)
- Phone field validates using `isValidPhoneNumber(...)`
- Demo password is:
  - `wavego123`
- On success:
  - `setAuthSession({ phone, verified: true })`
  - redirect → `getPostLoginRedirect()` or `/home`

### Continue with OTP (separate page)
- Clicking **Continue with OTP** navigates to:
  - `/otp` (and forwards `next/redirect` query if present)

---

## Signup (Design 02)

File: `src/components/auth/SignupView.tsx`

- Uses the same **Design 02** layout style as login (scene + services + card)
- Captures:
  - Full name
  - Phone (with country code)
  - Email (optional)
  - Password + Confirm password
  - Terms checkbox
- On submit:
  - stores pending profile in `sessionStorage` key `wavego-pending-profile`
  - navigates to `/otp?phone=<...>&mode=signup`

---

## OTP page (separate flow) — phone entry → verify section → login

File: `src/components/auth/OTPView.tsx`

This page supports both:
- **Login OTP** (`/otp`)
- **Signup verify** (`/otp?mode=signup&phone=...`)

### Flow
1. **Phone step**
   - user enters mobile number
   - click **Send OTP**
   - sets `setPendingOtpPhone(contact)`
   - switches to **Verify step**
2. **Verify step**
   - OTP input (6 digits) appears
   - as soon as 6 digits are entered, it auto-verifies
   - on success:
     - `setAuthSession({ phone, verified: true, ...profileIfSignup })`
     - redirect → `getPostLoginRedirect()` or `/home`

### Demo OTP rules
- Any 6-digit code works **except**:
  - `000000` → invalid

---

## Design 02 background + services panel

### Scene / background
File: `src/components/auth/LoginSceneDecor.tsx`

- Full-page background layers
- Dot grid overlay via `.wavego-dot-grid` (defined in `src/app/globals.css`)

### Left services panel (cards)
File: `src/components/auth/LoginServicesPanel.tsx`

- Uses `loginAuthServices` from `src/constants/services.ts`
- Each row uses 3D assets via:
  - `src/components/auth/AuthServiceImage.tsx`
  - which renders `src/components/home/ServiceImage.tsx` (`next/image`)

Assets referenced (expected under `public/images/...`):
- `/images/services/bike.png`
- `/images/services/parcel.png`
- `/images/services/ambulance.png`
- `/images/features/quick-pickup.png`

---

## “Barrel” exports

Auth barrel file: `src/components/auth/index.ts`

Exports commonly used views/components such as:
- `LoginView`, `SignupView`, `OTPView`
- `LoginSceneDecor`, `LoginServicesPanel`
- `OTPInput`, `CountryCodeSelector`, etc.

---

## How to run locally

```bash
npm install
npm run dev
```

Open:
- `http://localhost:3000/login`
- `http://localhost:3000/signup`
- `http://localhost:3000/otp`

---

## Quick test plan (manual)

- **Password login**
  - Go to `/login`
  - Enter valid phone + password `wavego123`
  - Should redirect to `/home`

- **OTP login**
  - Go to `/login` → click **Continue with OTP**
  - Enter phone → **Send OTP**
  - Enter OTP `123456` (anything except `000000`)
  - Should redirect to `/home`

- **OTP signup**
  - Go to `/signup` → fill details → submit
  - Should go to `/otp?mode=signup&phone=...`
  - Enter OTP (not `000000`)
  - Should redirect to `/home`

