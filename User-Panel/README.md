# WaveGo User — Mobile Application

Flutter mobile app for the WaveGo ride-hailing platform (passenger/user side).

> The original Next.js web app (including the marketing landing page) has been moved to `web-legacy/`. This Flutter app is **mobile-only** and starts with Splash → Onboarding → Phone Login.

## Tech Stack

- **Flutter** + **Dart**
- **Riverpod** — state management
- **Go Router** — navigation with bottom tab shell
- **Dio** — networking (mock mode by default)

## Architecture

```
lib/
├── core/          # Config, theme, routes, network, storage
├── models/        # Data models
├── services/      # API services
├── repositories/  # Repository layer
├── providers/     # Riverpod providers
├── screens/       # UI screens
├── widgets/       # Reusable components
└── main.dart
```

## App Flow

```
Splash → Onboarding (4 slides) → Phone Login → OTP → Home
```

**Bottom navigation:** Home | Bookings | Wallet | Profile

**Additional screens:** Notifications, Location search, Book ride, Ride tracking, Ambulance, Profile settings

## Getting Started

```bash
cd User-Panel
flutter pub get
flutter run
```

### Run on iPhone Simulator

```bash
open -a Simulator
sleep 10
flutter run
```

### Run with phone frame on macOS (dev)

```bash
flutter run -d macos
```

## Mock API Mode

By default `ENABLE_MOCK_API=true` uses JSON fixtures in `assets/mock/`.

```bash
flutter run --dart-define=ENABLE_MOCK_API=false --dart-define=API_BASE_URL=https://your-api.com/api/v1
```

## Test Credentials

- **OTP:** any 6 digits work in mock mode (except `000000`)

## WaveGo Design System

| Token | Value |
|-------|-------|
| Primary | `#31526E` |
| Secondary | `#D8B39F` |
| Background | `#FAF8F4` |
| Foreground | `#20242C` |

Typography: Satoshi headings, Inter body (`assets/fonts/`)

## Legacy Web App

The previous Next.js user panel (with landing page, blogs, safety pages) is preserved in `web-legacy/` for reference. It is not part of the mobile app.
