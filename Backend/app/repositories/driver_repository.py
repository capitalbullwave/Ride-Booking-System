import uuid
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Driver
from app.repositories.base import BaseRepository


class DriverRepository(BaseRepository[Driver]):
    def __init__(self, db: AsyncSession):
        super().__init__(Driver, db)

    async def get_by_email(self, email: str) -> Optional[Driver]:
        result = await self.db.execute(
            select(Driver).where(Driver.email == email, Driver.is_deleted == False)
        )
        return result.scalar_one_or_none()

    async def get_by_phone(self, phone: str) -> Optional[Driver]:
        result = await self.db.execute(
            select(Driver).where(Driver.phone == phone, Driver.is_deleted == False)
        )
        return result.scalar_one_or_none()

    async def get_by_id_active(self, driver_id: uuid.UUID) -> Optional[Driver]:
        result = await self.db.execute(
            select(Driver).where(
                Driver.id == driver_id, Driver.is_deleted == False, Driver.is_active == True
            )
        )
        return result.scalar_one_or_none()
