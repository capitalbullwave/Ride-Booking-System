import uuid
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    def __init__(self, db: AsyncSession):
        super().__init__(User, db)

    async def get_by_email(self, email: str) -> Optional[User]:
        result = await self.db.execute(
            select(User).where(User.email == email, User.is_deleted == False)
        )
        return result.scalar_one_or_none()

    async def get_by_phone(self, phone: str) -> Optional[User]:
        result = await self.db.execute(
            select(User).where(User.phone == phone, User.is_deleted == False)
        )
        return result.scalar_one_or_none()

    async def get_by_id_active(self, user_id: uuid.UUID) -> Optional[User]:
        result = await self.db.execute(
            select(User).where(User.id == user_id, User.is_deleted == False, User.is_active == True)
        )
        return result.scalar_one_or_none()
