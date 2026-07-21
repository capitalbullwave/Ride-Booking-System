# Driver Selfie Verification & Shift Lifecycle

Production gate that requires a live selfie before a driver can start a shift and accept rides. Built for Bull Wave Rides (Flutter Driver App + FastAPI + Admin Panel).

## Goals

- Selfie required **once per shift** before going online
- Never reuse yesterday’s verification
- Auto force-close stale shifts (crash / forgot offline / phone off)
- Pluggable face recognition + liveness providers
- Full audit trail for admin review

## Architecture

```
Driver-Panel (Flutter)
  └─ SelfieVerificationScreen (live camera only)
       ├─ GET  /driver/selfie/liveness-challenge
       ├─ POST /driver/selfie/verify
       └─ POST /driver/go-online

Backend
  app/selfie_verification/
    models.py          DriverShift, DriverSelfieLog
    service.py         Shift lifecycle + orchestration
    repository.py
    schemas.py
    storage.py         Encrypted selfie persistence
    face/              Pluggable face match providers
    liveness/          Pluggable liveness providers
  alembic/versions/030_driver_selfie_shifts.py

Admin-Panel
  /selfie-verifications
  Driver detail → Shifts / Selfie Checks tabs
```

## Flow

```
Go Online
  → GET /verification-status
  → if selfie_required → open camera
  → issue liveness challenge (blink, smile, head turn, anti-spoof)
  → capture live selfie (gallery disabled)
  → POST /selfie/verify  (liveness + face match)
  → on success → POST /go-online  (create shift, set ONLINE)
  → on failure → stay OFFLINE
```

Accept ride is also gated: `assert_can_accept_rides` requires an active `selfie_verified` shift.

## Shift rules

| Field | Description |
|-------|-------------|
| `status` | `active` \| `completed` \| `force_closed` |
| `selfie_verified` | Must be true to accept rides |
| `started_at` / `ended_at` | Shift window |

**Force close when:**

1. Active shift age **> 16 hours**, or
2. Shift calendar date **≠** current UTC date

When a shift is **completed** or **force-closed**, the driver is **always set offline** (DB + matching Redis), regardless of prior `online` / `busy` / `on_ride` status.

Celery beat task `force_close_stale_driver_shifts` runs every 5 minutes. The FastAPI app also runs the same job in a background loop every 5 minutes (so local/dev works without Celery). Closing a shift also happens opportunistically when the driver next hits verification/go-online APIs.

Going offline marks the active shift `completed`.

## APIs (driver JWT)

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/v1/driver/verification-status` | Whether selfie is required |
| GET | `/api/v1/driver/selfie/liveness-challenge` | Signed challenge |
| POST | `/api/v1/driver/selfie/verify` | Liveness + face match |
| POST | `/api/v1/driver/go-online` | Create/resume shift + online |
| POST | `/api/v1/driver/go-offline` | Complete shift + offline |
| GET | `/api/v1/driver/current-shift` | Active shift |
| PUT | `/api/v1/driver/go-online` | Legacy (same gate) |
| PUT | `/api/v1/driver/go-offline` | Legacy |

### Verify payload

```json
{
  "selfie_base64": "data:image/jpeg;base64,...",
  "challenge_id": "...",
  "liveness": {
    "blink": true,
    "smile": true,
    "head_turn": true,
    "anti_spoof": { "passed": true, "score": 0.85 }
  },
  "source": "live_camera"
}
```

`source` must be `live_camera`. Gallery uploads are rejected.

## Face providers

Configure via env:

```env
FACE_PROVIDER=insightface
# mock | aws_rekognition | azure_face | facepp | insightface | deepface
FACE_MATCH_THRESHOLD=68
LIVENESS_PROVIDER=instant_capture
# instant_capture | mock | client_challenge | aws_rekognition | azure_face
```

### InsightFace (recommended local / self-hosted)

Real face embeddings (no mock). Configure:

```env
FACE_PROVIDER=insightface
FACE_MATCH_THRESHOLD=68
```

**Engine order:**

1. `insightface` Python package + `buffalo_l` when installed (`pip install insightface`)
2. Else **OpenCV YuNet + SFace** (ArcFace-family ONNX) — works on Windows without MSVC

```bash
pip install opencv-python-headless onnxruntime numpy
# optional (Linux / with C++ Build Tools):
pip install insightface
```

First request downloads model weights (~few MB for SFace, or ~100MB+ for buffalo_l).
Use `FACE_MATCH_THRESHOLD` around **65–72**. Raise toward 75–80 for stricter matching.

`instant_capture` (default): open camera → capture selfie → match profile photo (no blink/smile steps).
`client_challenge`: blink / smile / head-turn gestures before capture.
Optional credentials:

```env
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=us-east-1
AZURE_FACE_ENDPOINT=
AZURE_FACE_KEY=
FACEPP_API_KEY=
FACEPP_API_SECRET=
```

Interface:

```python
async def verify_face(registered_image: bytes, live_selfie: bytes, *, threshold: float) -> FaceMatchResult
# FaceMatchResult(matched, confidence, provider, ...)
```

Default `mock` works without external APIs (dev/staging). Production should set a real provider.

## Liveness

Supported challenges: **blink**, **smile**, **head turn**, **anti-spoof**.

`client_challenge` issues an HMAC-signed challenge (2 minute TTL). The Flutter app guides the driver through actions, then posts results with the live selfie. Backend validates signature, expiry, and required actions.

## Security

- Live camera only (`source=live_camera`)
- Selfies stored under `uploads/selfies/{driver_id}/` with optional Fernet encryption (`SELFIE_ENCRYPT_AT_REST=true`)
- Every attempt logged in `driver_selfie_logs`
- Failed attempt rate limit: `SELFIE_MAX_FAILED_ATTEMPTS` (default 5) within `SELFIE_LOCKOUT_MINUTES` (default 30)
- Successful verify is consumable once and expires after `SELFIE_VERIFICATION_TTL_MINUTES` (default 10)
- Registered face = driver’s `profile_photo` from onboarding

## Admin APIs

| Method | Path |
|--------|------|
| GET | `/api/v1/admin/selfie-verifications` |
| GET | `/api/v1/admin/selfie-verifications/{id}` (includes decrypted image preview) |
| DELETE | `/api/v1/admin/selfie-verifications/{id}` (removes log + stored selfie) |
| GET | `/api/v1/admin/drivers/{id}/shifts` |
| GET | `/api/v1/admin/online-drivers/verified` |
| POST | `/api/v1/admin/drivers/{id}/force-offline` |

Admin UI: **Management → Selfie Verification**, plus driver detail **Shifts** / **Selfie Checks** tabs.

## Database

Migration: `030_driver_selfie_shifts.py`

```bash
cd Backend
alembic upgrade head
```

Tables:

- `driver_shifts`
- `driver_selfie_logs`

## Flutter entry points

- `lib/screens/verification/selfie_verification_screen.dart`
- `lib/services/selfie_verification_service.dart`
- `lib/providers/dashboard_provider.dart` — intercepts go-online with `SELFIE_REQUIRED`
- Route: `/selfie-verification`

## Error codes

| Code | Meaning |
|------|---------|
| `SELFIE_REQUIRED` | Must verify before online / accept |
| `NO_CAMERA_PERMISSION` | Client camera denied |
| `POOR_LIGHTING` | Image too small / low quality |
| `FACE_NOT_DETECTED` | No face in frame |
| `MULTIPLE_FACES` | More than one face |
| `LOW_CONFIDENCE` | Below match threshold |
| `LIVENESS_FAILED` | Challenge failed |
| `RATE_LIMITED` | Too many failures |
| `NETWORK_FAILURE` / `TIMEOUT` | Client connectivity |
| `GALLERY_NOT_ALLOWED` | Non-live source |

## Ops checklist

1. Run migration `030`
2. Ensure drivers have a registered `profile_photo`
3. Set `FACE_PROVIDER` for production
4. Run Celery worker + beat for stale shift cleanup
5. Confirm Admin → Selfie Verification loads
