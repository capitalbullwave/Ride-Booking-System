# WaveGo Driver Panel — Clean Architecture

This app follows **Clean Architecture** with feature-oriented modules. Layers map as follows:

| Layer | Location | Responsibility |
|-------|----------|----------------|
| **Presentation** | `screens/`, `widgets/`, `providers/` | UI, Riverpod controllers, navigation |
| **Domain** | `models/` | Entities, Freezed DTOs |
| **Data** | `repositories/`, `services/`, `core/network/` | API, local storage, mappers |

## Feature modules

```
lib/
├── core/                    # Shared infra (theme, network, storage, utils)
├── features/                # Feature entry points & docs (barrel exports)
│   ├── authentication/
│   ├── driver_registration/
│   ├── profile/
│   ├── rides/
│   └── ...
├── screens/                 # Presentation screens (by feature area)
├── providers/               # Riverpod StateNotifiers & DI
├── repositories/            # Repository pattern (thin wrappers)
├── services/                # Remote/local data sources (Dio)
└── models/                  # Domain models (Freezed)
```

## Registration flow (10 steps)

1. **Mobile verification** — `screens/auth/` (OTP login)
2. **Personal information** — `screens/registration/` step 0
3. **Profile photo** — step 1
4. **Driving license** — step 2
5. **Vehicle information** — step 3
6. **Vehicle documents** — step 4
7. **Identity verification (KYC)** — step 5
8. **Bank details** — step 6
9. **Emergency contact** — step 7
10. **Review & submit** — step 8

State: `RegistrationViewModel` + `registrationStepProvider`  
API: `POST /drivers/complete-registration` via `registration_payload.dart`

## State management

- **Riverpod** — `StateNotifierProvider` for features, `Provider` for DI
- **ViewState&lt;T&gt;** — `Initial | Loading | Success | Error` async pattern

## Key integrations

- **GoRouter** — `core/routes/app_router.dart`
- **Dio** — interceptors: auth, token refresh, error mapping
- **Secure storage** — JWT + refresh tokens
- **Connectivity** — offline banner via `ConnectivityBanner`

## Design system

See `AGENTS.md` and `core/theme/` for WaveGo Captain tokens (Material 3, Inter + Satoshi).
