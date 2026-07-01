import uuid
from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field, field_validator, model_validator

from app.schemas.common import BaseSchema
from app.utils.phone import normalize_phone


def _parse_flexible_date(value: object) -> date | None:
    if value is None or value == "":
        return None
    if isinstance(value, date) and not isinstance(value, datetime):
        return value
    if isinstance(value, datetime):
        return value.date()

    text = str(value).strip()
    if not text:
        return None

    for fmt in ("%Y-%m-%d", "%d/%m/%Y", "%d-%m-%Y", "%d.%m.%Y", "%m/%d/%Y"):
        try:
            return datetime.strptime(text, fmt).date()
        except ValueError:
            continue

    raise ValueError("Invalid date format. Use YYYY-MM-DD or DD/MM/YYYY")


class DriverRegister(BaseModel):
    email: EmailStr
    phone: str = Field(..., min_length=10, max_length=15)
    password: str = Field(..., min_length=8, max_length=100)
    first_name: str = Field(..., min_length=1, max_length=100)
    last_name: str = Field("", max_length=100)
    license_number: str = Field(..., min_length=5, max_length=50)

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        return normalize_phone(v)


class DriverRegisterOTPSend(BaseModel):
    phone: str = Field(..., min_length=10, max_length=15)
    password: str = Field(..., min_length=8, max_length=100)
    first_name: str = Field(..., min_length=1, max_length=100)
    last_name: str = Field("", max_length=100)
    email: EmailStr | None = None
    license_number: str = Field(default="PENDING", max_length=50)

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        return normalize_phone(v)


class DriverRegisterOTPVerify(BaseModel):
    phone: str = Field(..., min_length=10, max_length=15)
    otp: str = Field(..., min_length=4, max_length=6)

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        return normalize_phone(v)


class DriverLogin(BaseModel):
    phone: str | None = None
    email: EmailStr | None = None
    password: str

    @model_validator(mode="after")
    def require_phone_or_email(self):
        if not self.phone and not self.email:
            raise ValueError("Phone or email is required")
        if self.phone:
            self.phone = normalize_phone(self.phone)
        return self


class DriverPhoneOTPRequest(BaseModel):
    phone: str = Field(..., min_length=10, max_length=15)

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        return normalize_phone(v)


class DriverPhoneOTPVerify(BaseModel):
    phone: str = Field(..., min_length=10, max_length=15)
    otp: str = Field(..., min_length=4, max_length=6)

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        return normalize_phone(v)


class DriverUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    profile_photo: Optional[str] = None
    license_number: Optional[str] = None
    fcm_token: Optional[str] = None


class DriverDocumentCreate(BaseModel):
    document_type: str
    document_url: str
    document_number: Optional[str] = None
    expiry_date: Optional[datetime] = None


class DriverVehicleCreate(BaseModel):
    vehicle_type_id: uuid.UUID
    license_plate: str = Field(..., min_length=2, max_length=20)
    make: str = Field(default="", max_length=50)
    model: str = Field(default="Standard", min_length=1, max_length=50)
    color: str = Field(default="Unknown", min_length=1, max_length=30)
    year: int = Field(..., ge=1990, le=2030)

    @field_validator("license_plate")
    @classmethod
    def normalize_license_plate(cls, v: str) -> str:
        return v.strip().upper()

    @field_validator("model", mode="before")
    @classmethod
    def default_model(cls, v: str | None) -> str:
        if v is None or not str(v).strip():
            return "Standard"
        return str(v).strip()

    @field_validator("color", mode="before")
    @classmethod
    def default_color(cls, v: str | None) -> str:
        if v is None or not str(v).strip():
            return "Unknown"
        return str(v).strip()


class DriverDocumentResponse(BaseSchema):
    id: uuid.UUID
    document_type: str
    document_url: str
    document_number: Optional[str] = None
    status: str
    created_at: datetime


class DriverResponse(BaseSchema):
    id: uuid.UUID
    email: str
    phone: str
    first_name: str
    last_name: str
    profile_photo: Optional[str] = None
    license_number: Optional[str] = None
    kyc_status: str
    status: str
    is_active: bool
    is_verified: bool
    rating_avg: float
    total_rides: int
    created_at: datetime


class DriverLocationUpdate(BaseModel):
    lat: float = Field(..., ge=-90, le=90)
    lng: float = Field(..., ge=-180, le=180)
    heading: Optional[float] = None
    speed: Optional[float] = None


class DriverStatusUpdate(BaseModel):
    status: str


class DriverEarningsResponse(BaseModel):
    period: str
    total_rides: int
    total_earnings: float
    total_tips: float = 0.0
    net_earnings: float


class DriverBankCreate(BaseModel):
    account_holder_name: str = Field(..., min_length=2, max_length=150)
    account_number: str = Field(..., min_length=9, max_length=30)
    ifsc_code: str = Field(..., min_length=11, max_length=11)
    bank_name: str = Field(..., min_length=2, max_length=100)
    upi_id: Optional[str] = Field(default=None, max_length=100)

    @field_validator("ifsc_code")
    @classmethod
    def validate_ifsc(cls, v: str) -> str:
        import re

        code = v.strip().upper()
        if not re.match(r"^[A-Z]{4}0[A-Z0-9]{6}$", code):
            raise ValueError("Invalid IFSC code format (e.g. SBIN0001234)")
        return code


class DriverRegistrationDocument(BaseModel):
    document_type: str = Field(..., max_length=30)
    document_url: str = Field(
        ...,
        description="Base64 data URL (data:image/...;base64,...) or http(s) URL",
    )
    document_number: Optional[str] = Field(default=None, max_length=100)
    expiry_date: Optional[datetime] = None


class DriverRegistrationComplete(BaseModel):
    first_name: str = Field(..., min_length=1, max_length=100)
    last_name: str = Field(default="", max_length=100)
    email: Optional[EmailStr] = None
    date_of_birth: Optional[date] = None
    gender: Optional[str] = Field(default=None, max_length=20)
    referral_code: Optional[str] = Field(default=None, max_length=50)
    current_address: Optional[str] = Field(default=None, max_length=500)
    city: Optional[str] = Field(default=None, max_length=100)
    state: Optional[str] = Field(default=None, max_length=100)
    country: Optional[str] = Field(default=None, max_length=100)
    pin_code: Optional[str] = Field(default=None, max_length=20)
    license_number: str = Field(..., min_length=2, max_length=50)
    license_issue_date: Optional[date] = None
    license_expiry_date: Optional[date] = None
    profile_photo: Optional[str] = Field(
        default=None,
        description="Base64 data URL (data:image/...;base64,...) or http(s) URL",
    )
    vehicle: DriverVehicleCreate
    documents: list[DriverRegistrationDocument] = Field(default_factory=list)
    bank: Optional[DriverBankCreate] = None

    @field_validator("date_of_birth", "license_issue_date", "license_expiry_date", mode="before")
    @classmethod
    def parse_registration_dates(cls, value: object) -> date | None:
        return _parse_flexible_date(value)
