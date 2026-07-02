import json
from typing import List, Optional
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config.settings import settings
from app.core.constants import DriverStatus, KYCStatus
from app.core.exceptions import NotFoundException, ValidationException
from app.database.redis import get_redis
from app.models import Driver, DriverLocation, Ride, Vehicle
from app.repositories.driver_repository import DriverRepository

DRIVER_GEO_KEY = "drivers:geo"
DRIVER_META_PREFIX = "driver:meta:"
DRIVER_PENDING_PREFIX = "driver:pending:"
RIDE_REQUESTS_PREFIX = "ride:requests:"


class DriverMatchingService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.driver_repo = DriverRepository(db)

    async def _get_redis(self):
        try:
            return await get_redis()
        except Exception:
            return None

    async def _persist_driver_location(
        self,
        driver_id: UUID,
        lat: float,
        lng: float,
        heading: Optional[float] = None,
        speed: Optional[float] = None,
    ) -> None:
        result = await self.db.execute(
            select(DriverLocation).where(DriverLocation.driver_id == driver_id)
        )
        location = result.scalar_one_or_none()
        if location:
            location.lat = lat
            location.lng = lng
            location.heading = heading
            location.speed = speed
            location.is_available = True
        else:
            self.db.add(
                DriverLocation(
                    driver_id=driver_id,
                    lat=lat,
                    lng=lng,
                    heading=heading,
                    speed=speed,
                    is_available=True,
                )
            )
        await self.db.flush()

    async def update_driver_location(
        self,
        driver_id: UUID,
        lat: float,
        lng: float,
        heading: Optional[float] = None,
        speed: Optional[float] = None,
    ) -> None:
        await self._persist_driver_location(driver_id, lat, lng, heading, speed)

        redis = await self._get_redis()
        if not redis:
            return

        try:
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
        except Exception:
            pass

    async def set_driver_online(self, driver_id: UUID, lat: float, lng: float, vehicle_type_id: str) -> None:
        await self.update_driver_location(driver_id, lat, lng)

        redis = await self._get_redis()
        if not redis:
            return

        try:
            await redis.sadd("drivers:online", str(driver_id))
            await redis.hset(
                f"{DRIVER_META_PREFIX}{driver_id}",
                mapping={"vehicle_type_id": vehicle_type_id, "available": "1"},
            )
        except Exception:
            pass

    async def set_driver_offline(self, driver_id: UUID) -> None:
        redis = await self._get_redis()
        if not redis:
            return

        try:
            await redis.zrem(DRIVER_GEO_KEY, str(driver_id))
            await redis.srem("drivers:online", str(driver_id))
            await redis.delete(f"{DRIVER_META_PREFIX}{driver_id}")
        except Exception:
            pass

    async def _online_drivers_from_db(
        self,
        vehicle_type_id: Optional[str] = None,
        limit: int = 10,
    ) -> List[dict]:
        query = select(Driver).where(
            Driver.status == DriverStatus.ONLINE.value,
            Driver.kyc_status == KYCStatus.APPROVED.value,
            Driver.is_active.is_(True),
            Driver.is_deleted.is_(False),
        )
        if vehicle_type_id:
            query = (
                query.join(Vehicle, Vehicle.driver_id == Driver.id)
                .where(Vehicle.vehicle_type_id == UUID(vehicle_type_id))
                .distinct()
            )
        result = await self.db.execute(query.limit(limit))
        drivers = list(result.scalars().unique().all())

        items: List[dict] = []
        for driver in drivers:
            loc_result = await self.db.execute(
                select(DriverLocation).where(DriverLocation.driver_id == driver.id)
            )
            location = loc_result.scalar_one_or_none()
            items.append({
                "driver_id": str(driver.id),
                "distance_km": 0.0,
                "lat": location.lat if location else 0.0,
                "lng": location.lng if location else 0.0,
                "name": f"{driver.first_name} {driver.last_name}",
                "rating": driver.rating_avg,
            })
        return items

    async def find_nearby_drivers(
        self,
        lat: float,
        lng: float,
        vehicle_type_id: Optional[str] = None,
        radius_km: Optional[float] = None,
        limit: int = 10,
    ) -> List[dict]:
        redis = await self._get_redis()
        if not redis:
            return await self._online_drivers_from_db(vehicle_type_id, limit)

        radius = radius_km or settings.driver_search_radius_km
        radius_m = radius * 1000

        try:
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
        except Exception:
            return await self._online_drivers_from_db(vehicle_type_id, limit)

        drivers = []
        for driver_id, distance in results:
            try:
                meta = await redis.hgetall(f"{DRIVER_META_PREFIX}{driver_id}")
            except Exception:
                continue
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

        if not drivers:
            return await self._online_drivers_from_db(vehicle_type_id, limit)

        return drivers

    async def send_ride_request(self, ride_id: UUID, driver_ids: List[str]) -> None:
        redis = await self._get_redis()
        if not redis:
            return

        try:
            key = f"{RIDE_REQUESTS_PREFIX}{ride_id}"
            for driver_id in driver_ids:
                await redis.sadd(key, driver_id)
                await redis.sadd(f"{DRIVER_PENDING_PREFIX}{driver_id}", str(ride_id))
                await redis.publish(
                    "ride_requests",
                    json.dumps({"ride_id": str(ride_id), "driver_id": driver_id}),
                )
            await redis.expire(key, settings.driver_request_timeout_seconds)
            for driver_id in driver_ids:
                await redis.expire(
                    f"{DRIVER_PENDING_PREFIX}{driver_id}",
                    settings.driver_request_timeout_seconds,
                )
        except Exception:
            pass

    async def get_pending_ride_ids(self, driver_id: UUID) -> List[UUID]:
        redis = await self._get_redis()
        if not redis:
            return []

        try:
            pending = await redis.smembers(f"{DRIVER_PENDING_PREFIX}{driver_id}")
            if pending:
                return [UUID(ride_id) for ride_id in pending]
        except Exception:
            pass
        return []

    async def clear_driver_pending(self, driver_id: UUID, ride_id: UUID) -> None:
        redis = await self._get_redis()
        if not redis:
            return

        try:
            await redis.srem(f"{DRIVER_PENDING_PREFIX}{driver_id}", str(ride_id))
            await redis.srem(f"{RIDE_REQUESTS_PREFIX}{ride_id}", str(driver_id))
        except Exception:
            pass

    async def _online_drivers_for_ride(self, ride: Ride) -> List[Driver]:
        matched = await self.db.execute(
            select(Driver)
            .join(Vehicle, Vehicle.driver_id == Driver.id)
            .where(
                Driver.status == DriverStatus.ONLINE.value,
                Driver.kyc_status == KYCStatus.APPROVED.value,
                Driver.is_active.is_(True),
                Driver.is_deleted.is_(False),
                Vehicle.vehicle_type_id == ride.vehicle_type_id,
            )
            .distinct()
        )
        drivers = list(matched.scalars().unique().all())
        if drivers:
            return drivers

        fallback = await self.db.execute(
            select(Driver).where(
                Driver.status == DriverStatus.ONLINE.value,
                Driver.kyc_status == KYCStatus.APPROVED.value,
                Driver.is_active.is_(True),
                Driver.is_deleted.is_(False),
            )
        )
        return list(fallback.scalars().all())

    async def dispatch_ride_to_online_drivers(self, ride: Ride, ws_manager=None) -> int:
        from app.notifications.service import NotificationService

        drivers = await self._online_drivers_for_ride(ride)
        if not drivers:
            return 0

        driver_ids = [str(driver.id) for driver in drivers]
        try:
            await self.send_ride_request(ride.id, driver_ids)
        except Exception:
            pass

        notif_service = NotificationService(self.db)
        payload = {
            "event": "ride_request",
            "ride_id": str(ride.id),
            "pickup_address": ride.pickup_address,
            "dropoff_address": ride.dropoff_address,
            "pickup_lat": ride.pickup_lat,
            "pickup_lng": ride.pickup_lng,
            "dropoff_lat": ride.dropoff_lat,
            "dropoff_lng": ride.dropoff_lng,
            "estimated_fare": ride.estimated_fare,
            "estimated_distance_km": ride.estimated_distance_km,
            "estimated_duration_min": ride.estimated_duration_min,
            "payment_method": ride.payment_method,
            "status": ride.status,
        }

        for driver in drivers:
            await notif_service.create_in_app(
                title="New ride request",
                message=f"Pickup: {ride.pickup_address}",
                notification_type="RIDE",
                driver_id=driver.id,
                data=payload,
            )
            if ws_manager:
                await ws_manager.send_personal(str(driver.id), payload)

        return len(drivers)

    async def ensure_driver_online(self, driver: Driver, lat: float, lng: float) -> None:
        vehicle_result = await self.db.execute(
            select(Vehicle).where(Vehicle.driver_id == driver.id).limit(1)
        )
        vehicle = vehicle_result.scalar_one_or_none()
        vehicle_type_id = str(vehicle.vehicle_type_id) if vehicle else ""
        await self.set_driver_online(driver.id, lat, lng, vehicle_type_id)

    async def driver_default_location(self, driver_id: UUID) -> tuple[float, float]:
        result = await self.db.execute(
            select(DriverLocation).where(DriverLocation.driver_id == driver_id)
        )
        location = result.scalar_one_or_none()
        if location:
            return location.lat, location.lng
        return 28.6139, 77.2090
