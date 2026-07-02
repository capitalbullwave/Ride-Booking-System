"""Save base64 image payloads to disk and return a public URL path."""
import base64
import binascii
import re
import uuid
from pathlib import Path

from app.core.config import settings

_DATA_URL_RE = re.compile(
    r"^data:image/(?P<fmt>[a-zA-Z0-9.+-]+);base64,(?P<data>.+)$",
    re.DOTALL,
)

_EXT_BY_FMT = {
    "jpeg": "jpg",
    "jpg": "jpg",
    "png": "png",
    "webp": "webp",
    "gif": "gif",
}


def _upload_root() -> Path:
    root = Path(settings.upload_dir)
    root.mkdir(parents=True, exist_ok=True)
    return root


def persist_driver_image(value: str | None, driver_id: str, prefix: str) -> str | None:
    """Accept http(s) URL or data:image/...;base64,... and return stored path."""
    if not value or not value.strip():
        return None

    text = value.strip()
    if text.startswith("http://") or text.startswith("https://"):
        return text

    match = _DATA_URL_RE.match(text)
    if not match:
        return text

    fmt = match.group("fmt").lower()
    ext = _EXT_BY_FMT.get(fmt, "jpg")
    try:
        raw = base64.b64decode(match.group("data"), validate=True)
    except (binascii.Error, ValueError):
        return text

    if not raw:
        return None

    folder = _upload_root() / "drivers" / str(driver_id)
    folder.mkdir(parents=True, exist_ok=True)
    filename = f"{prefix}_{uuid.uuid4().hex[:12]}.{ext}"
    file_path = folder / filename
    file_path.write_bytes(raw)

    return f"/uploads/drivers/{driver_id}/{filename}"


def persist_vehicle_type_image(value: str | None, vehicle_type_id: str, prefix: str = "icon") -> str | None:
    """Accept http(s) URL or data:image/...;base64,... and return stored path."""
    if not value or not value.strip():
        return None

    text = value.strip()
    if text.startswith("http://") or text.startswith("https://"):
        return text

    if text.startswith("/uploads/"):
        return text

    match = _DATA_URL_RE.match(text)
    if not match:
        return None

    fmt = match.group("fmt").lower()
    ext = _EXT_BY_FMT.get(fmt, "jpg")
    try:
        raw = base64.b64decode(match.group("data"), validate=True)
    except (binascii.Error, ValueError):
        return None

    if not raw:
        return None

    folder = _upload_root() / "vehicles" / str(vehicle_type_id)
    folder.mkdir(parents=True, exist_ok=True)
    filename = f"{prefix}_{uuid.uuid4().hex[:12]}.{ext}"
    file_path = folder / filename
    file_path.write_bytes(raw)

    return f"/uploads/vehicles/{vehicle_type_id}/{filename}"
