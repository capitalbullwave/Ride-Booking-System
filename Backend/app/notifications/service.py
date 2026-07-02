"""Notification service - Push, Email, SMS, In-App."""
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Notification
from app.tasks.celery_app import send_notification


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
