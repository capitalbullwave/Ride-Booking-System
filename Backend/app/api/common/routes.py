"""Shared APIs — /api/v1/common/*"""
from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.session import get_db
from app.models import AppSetting, VehicleType

router = APIRouter(tags=["Common"])

DEFAULT_CITIES = [
    {"id": "delhi", "name": "Delhi", "country": "India"},
    {"id": "mumbai", "name": "Mumbai", "country": "India"},
    {"id": "bangalore", "name": "Bangalore", "country": "India"},
]


@router.get("/vehicle-types")
async def vehicle_types(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(VehicleType).where(VehicleType.is_active == True))
    return [
        {
            "id": str(vt.id),
            "slug": vt.name.lower().replace(" ", "-"),
            "name": vt.name,
            "description": vt.description,
            "base_fare": vt.base_fare,
            "per_km_rate": vt.per_km_rate,
            "icon_url": vt.icon,
        }
        for vt in result.scalars().all()
    ]


@router.get("/cities")
async def cities():
    return DEFAULT_CITIES


@router.get("/app-settings")
async def app_settings(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(AppSetting).where(AppSetting.is_public == True))
    settings = {row.key: row.value for row in result.scalars().all()}
    return {
        "app_name": settings.get("app_name", "WaveGo"),
        "contact_email": settings.get("contact_email", "support@ridebook.com"),
        "contact_phone": settings.get("contact_phone", "+91 98765 43210"),
    }


@router.get("/pricing")
async def pricing(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(VehicleType).where(VehicleType.is_active == True))
    return [
        {
            "vehicle_type_id": str(vt.id),
            "name": vt.name,
            "base_fare": vt.base_fare,
            "per_km_rate": vt.per_km_rate,
            "waiting_charge_per_min": vt.waiting_charge_per_min,
        }
        for vt in result.scalars().all()
    ]


@router.get("/banners", include_in_schema=False)
async def banners():
    return []


@router.get("/support/faqs")
async def faqs():
    return [
        {"category": "Rides", "question": "How do I book a ride?", "answer": "Enter pickup and drop locations and confirm."},
        {"category": "Payments", "question": "What payment methods are supported?", "answer": "Cash, wallet, UPI, and card."},
    ]
