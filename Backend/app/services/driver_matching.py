import json
from typing import List, Optional
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.config.settings import settings
from app.core.constants import DriverStatus, KYCStatus
from app.core.exceptions import NotFoundException, ValidationException
from app.database.redis import get_redis
from app.models import DriverLocation
from app.repositories.driver_repository import DriverRepository

DRIVER_GEO_KEY = "drivers:geo"
DRIVER_META_PREFIX = "driver:meta:"


class DriverMatchingService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.driver_repo = DriverRepository(db)

    async def update_driver_location(
        self,
        driver_id: UUID,
        lat: float,
        lng: float,
        heading: Optional[float] = None,
        speed: Optional[float] = None,
    ) -> None:
        redis = await get_redis()
        await redis.geoadd(DRIVER_GEO_KEY, (lng, lat, str(driver_id)))
        await redis.hset(
            f"{DRIVER_META_PREFIX}{driver_id}",
            mapping={
                "lat": str(lat),
                "lng": str(lng),
                "heading": str(heading or 0),
                "speed": str(speed or 0),
            },
        )
        await redis.expire(f"{DRIVER_META_PREFIX}{driver_id}", 300)

    async def set_driver_online(self, driver_id: UUID, lat: float, lng: float, vehicle_type_id: str) -> None:
        redis = await get_redis()
        await self.update_driver_location(driver_id, lat, lng)
        await redis.sadd("drivers:online", str(driver_id))
        await redis.hset(
            f"{DRIVER_META_PREFIX}{driver_id}",
            mapping={"vehicle_type_id": vehicle_type_id, "available": "1"},
        )

    async def set_driver_offline(self, driver_id: UUID) -> None:
        redis = await get_redis()
        await redis.zrem(DRIVER_GEO_KEY, str(driver_id))
        await redis.srem("drivers:online", str(driver_id))
        await redis.delete(f"{DRIVER_META_PREFIX}{driver_id}")

    async def find_nearby_drivers(
        self,
        lat: float,
        lng: float,
        vehicle_type_id: Optional[str] = None,
        radius_km: Optional[float] = None,
        limit: int = 10,
    ) -> List[dict]:
        redis = await get_redis()
        radius = radius_km or settings.driver_search_radius_km
        radius_m = radius * 1000

        results = await redis.geosearch(
            DRIVER_GEO_KEY,
            longitude=lng,
            latitude=lat,
            radius=radius_m,
            unit="m",
            sort="ASC",
            count=limit * 2,
            withdist=True,
        )

        drivers = []
        for driver_id, distance in results:
            meta = await redis.hgetall(f"{DRIVER_META_PREFIX}{driver_id}")
            if not meta or meta.get("available") != "1":
                continue
            if vehicle_type_id and meta.get("vehicle_type_id") != vehicle_type_id:
                continue

            driver = await self.driver_repo.get_by_id(UUID(driver_id))
            if not driver or driver.status != DriverStatus.ONLINE.value:
                continue
            if driver.kyc_status != KYCStatus.APPROVED.value:
                continue

            drivers.append({
                "driver_id": driver_id,
                "distance_km": round(float(distance) / 1000, 2),
                "lat": float(meta.get("lat", 0)),
                "lng": float(meta.get("lng", 0)),
                "name": f"{driver.first_name} {driver.last_name}",
                "rating": driver.rating_avg,
            })

            if len(drivers) >= limit:
                break

        return drivers

    async def send_ride_request(self, ride_id: UUID, driver_ids: List[str]) -> None:
        redis = await get_redis()
        key = f"ride:requests:{ride_id}"
        for driver_id in driver_ids:
            await redis.sadd(key, driver_id)
            await redis.publish(
                "ride_requests",
                json.dumps({"ride_id": str(ride_id), "driver_id": driver_id}),
            )
        await redis.expire(key, settings.driver_request_timeout_seconds)
