# WaveGo Captain — Driver Application

Production-ready Flutter driver app for the WaveGo ride-hailing platform.

## Tech Stack

- **Flutter** (latest stable) + **Dart**
- **Riverpod** — state management (MVVM)
- **Go Router** — navigation
- **Dio** — networking with interceptors
- **Freezed + Json Serializable** — models
- **Google Maps**, **Geolocator**, **Firebase Messaging**, **Secure Storage**, and more

## Architecture

```
lib/
├── core/          # Config, theme, routes, network, storage, utils
├── models/        # Freezed data models
├── services/      # API services (Dio)
├── repositories/  # Repository layer
├── providers/     # Riverpod view models
├── screens/       # UI screens
├── widgets/       # Reusable components
└── main.dart
```

Clean Architecture with MVVM: **Screens → Providers (ViewModels) → Repositories → Services → API**

## Phone-Only Mode

This app is **mobile phone only** (portrait, no tablet/desktop layouts):

- Portrait locked on Android & iOS
- On macOS/desktop dev builds, UI renders inside a **centered phone frame** (390×844)
- Use a phone simulator or device — not macOS desktop layout

### Run on iPhone Simulator (recommended)

**Do NOT use Chrome/browser.** Web is disabled for this project.

```bash
# One command — boots simulator + runs app
./scripts/run_phone.sh
```

Or manually (wait ~10s after opening Simulator):

```bash
open -a Simulator
sleep 10
xcrun simctl boot B7309CC1-9C83-4C46-8C38-24D3621B668E
flutter run -d B7309CC1-9C83-4C46-8C38-24D3621B668E
```

**In Cursor/VS Code:** Run & Debug → select **"WaveGo — iPhone Simulator"** (not Chrome).

### If iPhone build fails (iOS 26.5 not installed)

Xcode SDK (26.5) must match the simulator runtime. Install it:

**Xcode → Settings → Components → iOS 26.5 → Download**

Or run terminal:
```bash
xcodebuild -downloadPlatform iOS
```

### Run with phone frame on macOS (dev fallback)

```bash
flutter run -d macos
```

Or use the helper script:

```bash
chmod +x scripts/run_phone.sh
./scripts/run_phone.sh
```

## Getting Started

```bash
cd Driver-Panel
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Mock API Mode

By default the app connects to the local backend at `http://127.0.0.1:8000/api/v1`. To use mock JSON fixtures instead:

```bash
flutter run --dart-define=ENABLE_MOCK_API=true
```

To point at a different backend:

```bash
flutter run --dart-define=API_BASE_URL=http://your-host:8000/api/v1
```

**Android emulator:** use `http://10.0.2.2:8000/api/v1` instead of `127.0.0.1`.

## Test Credentials

- **OTP:** `123456` (when backend runs in debug without Twilio)
- **Mock mode OTP:** `123456`

## App Flow

Splash → Onboarding → Phone Login → OTP → Registration (8 steps) → Verification Pending → Dashboard

When online: Ride Request → Active Trip → Payment → Ride Summary

## Screens

| Module | Screens |
|--------|---------|
| Auth | Splash, Onboarding (4), Phone Login, OTP |
| Registration | 8-step multi-form + Review |
| Dashboard | Home, Online toggle, Stats |
| Rides | Request, Active Trip, Payment, Summary |
| Trips | History, Detail, Earnings |
| Wallet | Balance, Withdraw, Transactions |
| Profile | Edit, Documents, Settings |
| Support | FAQ, Tickets, Live Chat, SOS |

## WaveGo Design System

The app uses WaveGo brand tokens (not competitor colors). Full reference: `AGENTS.md` and `lib/core/theme/`.

| Token | Value | Usage |
|-------|-------|--------|
| Primary | `#31526E` | Buttons, headings, key actions |
| Secondary | `#D8B39F` | Accents, icon backgrounds |
| Background | `#FAF8F4` | Page background |
| Foreground | `#20242C` | Body text |
| Muted | `#E8E4DD` / `#6086A8` | Borders, secondary text |
| Success / Warning / Error | `#5FA87A` / `#E8A95A` / `#D66B6B` | Status states |

- **Typography**: Satoshi headings, Inter body (`assets/fonts/`)
- **Radius**: buttons 16px, cards 20px, inputs 18px (`AppRadius`)

## Backend Integration

The driver app talks to the FastAPI backend under `/api/v1/driver/*` and `/api/v1/auth/*`.

| Feature | Endpoint |
|---------|----------|
| OTP login | `POST /auth/send-otp`, `POST /auth/verify-otp` |
| Profile | `GET/PUT /driver/profile` |
| Go online/offline | `PUT /driver/go-online`, `PUT /driver/go-offline` |
| Location | `POST /driver/location` |
| Ride requests | `GET /driver/ride-requests` |
| Accept/reject | `POST /driver/accept-ride`, `POST /driver/reject-ride` |
| Ride lifecycle | `POST /driver/arrived-ride`, `start-ride`, `end-ride` |
| History & wallet | `GET /driver/ride-history`, `/driver/wallet`, `/driver/earnings` |

Start the backend first:

```bash
cd Backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Then run the driver app from `Driver-Panel/`.
