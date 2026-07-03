"""Notification service - Push, Email, SMS, In-App."""
from datetime import datetime, timezone
from uuid import UUID

from sqlalchemy import func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException
from app.models import Notification
from app.tasks.celery_app import send_notification

_DRIVER_TYPE_MAP = {
    "RIDE": "ride",
    "PROMO": "offer",
    "PAYMENT": "bonus",
    "SYSTEM": "system",
    "ADMIN": "system",
    "ADMIN_BROADCAST": "system",
    "CHAT": "system",
}


def map_driver_notification_type(notification_type: str) -> str:
    return _DRIVER_TYPE_MAP.get((notification_type or "SYSTEM").upper(), "system")


def serialize_driver_notification(notification: Notification) -> dict:
    return {
        "id": str(notification.id),
        "title": notification.title,
        "body": notification.message,
        "type": map_driver_notification_type(notification.notification_type),
        "read": notification.is_read,
        "created_at": notification.created_at.isoformat(),
        "data": notification.data,
    }


class NotificationService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_in_app(
        self,
        title: str,
        message: str,
        notification_type: str = "SYSTEM",
        user_id: UUID | None = None,
        driver_id: UUID | None = None,
        data: dict | None = None,
    ) -> Notification:
        notification = Notification(
            user_id=user_id,
            driver_id=driver_id,
            title=title,
            message=message,
            notification_type=notification_type,
            data=data,
        )
        self.db.add(notification)
        await self.db.flush()
        await self.db.refresh(notification)
        return notification

    async def send_push(self, user_id: str, title: str, message: str, data: dict | None = None):
        send_notification.delay(user_id, title, message, data)

    async def send_ride_notification(self, ride_id: str, event: str, user_id: UUID, driver_id: UUID | None = None):
        messages = {
            "ride_accepted": ("Ride Accepted", "Your driver is on the way!"),
            "driver_arrived": ("Driver Arrived", "Your driver has arrived at pickup location"),
            "ride_started": ("Ride Started", "Your ride has started. Enjoy your trip!"),
            "ride_completed": ("Ride Completed", "Your ride is complete. Please rate your driver."),
            "ride_cancelled": ("Ride Cancelled", "Your ride has been cancelled."),
        }
        title, message = messages.get(event, ("Ride Update", f"Ride status: {event}"))
        await self.create_in_app(title, message, "RIDE", user_id=user_id, data={"ride_id": ride_id, "event": event})
        await self.send_push(str(user_id), title, message, {"ride_id": ride_id})

    async def list_for_driver(
        self,
        driver_id: UUID,
        page: int = 1,
        page_size: int = 50,
    ) -> tuple[list[Notification], int, int]:
        base = select(Notification).where(Notification.driver_id == driver_id)
        total_result = await self.db.execute(select(func.count()).select_from(base.subquery()))
        total = int(total_result.scalar_one())

        unread_result = await self.db.execute(
            select(func.count()).where(
                Notification.driver_id == driver_id,
                Notification.is_read.is_(False),
            )
        )
        unread_count = int(unread_result.scalar_one())

        result = await self.db.execute(
            base.order_by(Notification.created_at.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
        )
        return list(result.scalars().all()), total, unread_count

    async def mark_driver_notification_read(self, notification_id: UUID, driver_id: UUID) -> Notification:
        result = await self.db.execute(
            select(Notification).where(
                Notification.id == notification_id,
                Notification.driver_id == driver_id,
            )
        )
        notification = result.scalar_one_or_none()
        if not notification:
            raise NotFoundException("Notification not found")
        if not notification.is_read:
            notification.is_read = True
            notification.read_at = datetime.now(timezone.utc)
            await self.db.flush()
            await self.db.refresh(notification)
        return notification

    async def mark_all_driver_notifications_read(self, driver_id: UUID) -> int:
        result = await self.db.execute(
            update(Notification)
            .where(
                Notification.driver_id == driver_id,
                Notification.is_read.is_(False),
            )
            .values(is_read=True, read_at=datetime.now(timezone.utc))
        )
        await self.db.flush()
        return int(result.rowcount or 0)
