"""Public APIs — /api/v1/public/*"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.public.schemas import (
    DirectionsResponse,
    LatLngPoint,
    PlaceSearchResponse,
    PlaceSuggestion,
    RoutePoint,
)
from app.database.session import get_db
from app.maps.service import MapsService
from app.models import AppSetting

router = APIRouter(tags=["Public"])


def get_maps_service() -> MapsService:
    return MapsService()


@router.get("/places/search", response_model=PlaceSearchResponse)
async def search_places(
    q: str = Query(..., min_length=2, max_length=120, description="Location search text"),
    limit: int = Query(8, ge=1, le=15),
    country: str = Query("in", min_length=2, max_length=2),
    maps: MapsService = Depends(get_maps_service),
):
    rows = await maps.search_places(q, limit=limit, country=country.lower())
    return PlaceSearchResponse(
        query=q.strip(),
        results=[PlaceSuggestion(**row) for row in rows],
    )


@router.get("/places/directions", response_model=DirectionsResponse)
async def get_directions(
    pickup: str = Query(..., min_length=3, max_length=300),
    dropoff: str = Query(..., min_length=3, max_length=300),
    maps: MapsService = Depends(get_maps_service),
):
    route = await maps.get_route_between(pickup, dropoff)
    if not route:
        raise HTTPException(status_code=404, detail="Could not calculate route for these locations")

    return DirectionsResponse(
        pickup=RoutePoint(**route["pickup"]),
        dropoff=RoutePoint(**route["dropoff"]),
        distance_km=round(route["distance_km"], 2),
        duration_min=round(route["duration_min"], 1),
        path=[LatLngPoint(**point) for point in route["path"]],
        source=route["source"],
    )

@router.get("/privacy-policy")
async def privacy_policy(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(AppSetting).where(AppSetting.key == "privacy_policy"))
    setting = result.scalar_one_or_none()
    content = setting.value if setting else "<p>Your privacy is important to us.</p>"
    return {"title": "Privacy Policy", "content": content}


@router.get("/terms")
async def terms(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(AppSetting).where(AppSetting.key == "terms_of_service"))
    setting = result.scalar_one_or_none()
    content = setting.value if setting else "<p>By using the app you agree to our terms.</p>"
    return {"title": "Terms of Service", "content": content}


@router.get("/about")
async def about(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(AppSetting).where(AppSetting.is_public == True))
    settings = {row.key: row.value for row in result.scalars().all()}
    return {
        "app_name": settings.get("app_name", "WaveGo"),
        "description": settings.get("about", "Ride booking platform"),
        "contact_email": settings.get("contact_email", "support@ridebook.com"),
    }


@router.get("/contact")
async def contact(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(AppSetting).where(AppSetting.is_public == True))
    settings = {row.key: row.value for row in result.scalars().all()}
    return {
        "email": settings.get("contact_email", "support@ridebook.com"),
        "phone": settings.get("contact_phone", "+91 98765 43210"),
        "address": settings.get("contact_address", "India"),
    }
