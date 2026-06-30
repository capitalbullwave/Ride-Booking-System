import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field, field_validator, model_validator

from app.schemas.common import BaseSchema
from app.utils.phone import normalize_phone


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
