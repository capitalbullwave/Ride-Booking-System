"""User module service."""
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User, VehicleType
from app.repositories.ride_repository import RideRepository


class UserApiService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.ride_repo = RideRepository(db)

    async def home_dashboard(self, user: User) -> dict:
        vt_result = await self.db.execute(select(VehicleType).where(VehicleType.is_active == True))
        vehicle_types = vt_result.scalars().all()
        recent = await self.ride_repo.get_user_rides(user.id, page=1, page_size=5)
        active = await self.ride_repo.get_active_ride_for_user(user.id)
        return {
            "greeting_name": user.first_name,
            "vehicle_categories": [
                {
                    "id": str(vt.id),
                    "slug": vt.name.lower().replace(" ", "-"),
                    "name": vt.name,
                    "description": vt.description,
                    "base_fare": vt.base_fare,
                    "per_km_rate": vt.per_km_rate,
                    "icon_url": vt.icon,
                }
                for vt in vehicle_types
            ],
            "offers": [],
            "banners": [],
            "nearby_drivers_count": 0,
            "recent_rides": [
                {
                    "id": str(r.id),
                    "pickup_address": r.pickup_address,
                    "dropoff_address": r.dropoff_address,
                    "status": r.status,
                    "fare_estimate": r.estimated_fare,
                    "created_at": r.created_at.isoformat(),
                }
                for r in recent
            ],
            "active_ride": None if not active else {"id": str(active.id), "status": active.status},
        }


__all__ = ["UserApiService"]
