"""User Panel API — /api/v1/user/*"""
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, Field
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.user.dependencies import get_current_user
from app.api.user.service import UserApiService
from app.core.constants import SupportTicketPriority, SupportTicketStatus
from app.core.exceptions import ForbiddenException, NotFoundException
from app.database.session import get_db
from app.models import Notification, Ride, SavedAddress, SupportTicket, User, VehicleType
from app.repositories.ride_repository import RideRepository
from app.repositories.user_repository import UserRepository
from app.schemas.payment import WalletTopUp, WalletTransactionResponse
from app.schemas.ride import RideCancel, RideCreate, RideDetailResponse, RideResponse
from app.services.payment_service import WalletService
from app.services.ride_service import RideService
from app.api.websocket.manager import manager
from app.utils.phone import format_phone_display

router = APIRouter(tags=["User"])


class ProfileUpdate(BaseModel):
    full_name: str | None = None
    email: str | None = None
    emergency_contact_name: str | None = None
    emergency_contact_phone: str | None = None


class SavedAddressCreate(BaseModel):
    label: str
    address_line: str
    latitude: float | None = None
    longitude: float | None = None
    is_default: bool = False


class BookRideRequest(BaseModel):
    pickup_address: str
    dropoff_address: str
    pickup_lat: float = 28.6328
    pickup_lng: float = 77.2167
    dropoff_lat: float = 28.4595
    dropoff_lng: float = 77.0266
    vehicle_category_id: str | None = None
    payment_method: str = "CASH"


class SupportRequest(BaseModel):
    subject: str
    message: str


class CancelRideRequest(BaseModel):
    ride_id: UUID
    reason: str | None = None


class PaymentRequest(BaseModel):
    amount: float = Field(gt=0)
    description: str = "Wallet top-up"


def _address_response(address: SavedAddress) -> dict:
    return {
        "id": str(address.id),
        "label": address.label,
        "address_line": address.address,
        "latitude": address.lat,
        "longitude": address.lng,
        "is_default": address.is_default,
    }


def _user_to_profile(user: User, addresses: list[SavedAddress]) -> dict:
    return {
        "id": str(user.id),
        "phone": format_phone_display(user.phone),
        "full_name": f"{user.first_name} {user.last_name}".strip(),
        "email": user.email,
        "profile_image_url": user.profile_photo,
        "emergency_contact_name": user.emergency_contact_name,
        "emergency_contact_phone": user.emergency_contact_phone,
        "addresses": [_address_response(a) for a in addresses],
    }


def _ride_summary(ride: Ride) -> dict:
    return {
        "id": str(ride.id),
        "pickup_address": ride.pickup_address,
        "dropoff_address": ride.dropoff_address,
        "status": ride.status,
        "fare_estimate": ride.estimated_fare,
        "fare_final": ride.final_fare,
        "created_at": ride.created_at.isoformat(),
    }


@router.get("/profile")
async def get_profile(user: Annotated[User, Depends(get_current_user)], db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(SavedAddress).where(SavedAddress.user_id == user.id, SavedAddress.is_deleted == False)
    )
    return _user_to_profile(user, list(result.scalars().all()))


@router.put("/profile")
@router.patch("/profile")
async def update_profile(
    data: ProfileUpdate,
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    if data.full_name:
        parts = data.full_name.strip().split(" ", 1)
        user.first_name = parts[0]
        user.last_name = parts[1] if len(parts) > 1 else ""
    if data.email is not None:
        user.email = data.email
    if data.emergency_contact_name is not None:
        user.emergency_contact_name = data.emergency_contact_name
    if data.emergency_contact_phone is not None:
        user.emergency_contact_phone = data.emergency_contact_phone
    await UserRepository(db).update(user)
    result = await db.execute(select(SavedAddress).where(SavedAddress.user_id == user.id))
    return _user_to_profile(user, list(result.scalars().all()))


async def _list_user_addresses(user: User, db: AsyncSession) -> list[dict]:
    result = await db.execute(
        select(SavedAddress).where(SavedAddress.user_id == user.id, SavedAddress.is_deleted == False)
    )
    return [_address_response(a) for a in result.scalars().all()]


@router.get("/profile/addresses")
async def list_profile_addresses(
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    return await _list_user_addresses(user, db)


@router.post("/profile/addresses", status_code=201)
async def create_profile_address(
    data: SavedAddressCreate,
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    if data.is_default:
        existing = await db.execute(
            select(SavedAddress).where(
                SavedAddress.user_id == user.id,
                SavedAddress.is_deleted == False,
                SavedAddress.is_default == True,
            )
        )
        for row in existing.scalars().all():
            row.is_default = False

    address = SavedAddress(
        user_id=user.id,
        label=data.label,
        address=data.address_line,
        lat=data.latitude if data.latitude is not None else 0.0,
        lng=data.longitude if data.longitude is not None else 0.0,
        is_default=data.is_default,
    )
    db.add(address)
    await db.commit()
    await db.refresh(address)
    return _address_response(address)


@router.delete("/profile/addresses/{address_id}")
async def delete_profile_address(
    address_id: UUID,
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(SavedAddress).where(
            SavedAddress.id == address_id,
            SavedAddress.user_id == user.id,
            SavedAddress.is_deleted == False,
        )
    )
    address = result.scalar_one_or_none()
    if not address:
        raise NotFoundException("Address not found")
    address.soft_delete()
    await db.commit()
    return {"message": "Address deleted", "success": True}


@router.get("/saved-address")
async def saved_addresses(user: Annotated[User, Depends(get_current_user)], db: AsyncSession = Depends(get_db)):
    return await _list_user_addresses(user, db)


@router.post("/book-ride")
async def book_ride(
    data: BookRideRequest,
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    if not data.vehicle_category_id:
        vt_result = await db.execute(select(VehicleType).where(VehicleType.is_active == True).limit(1))
        vt = vt_result.scalar_one_or_none()
        if not vt:
            raise NotFoundException("No vehicle types available")
        vehicle_type_id = vt.id
    else:
        vehicle_type_id = UUID(data.vehicle_category_id)

    ride_data = RideCreate(
        pickup_address=data.pickup_address,
        pickup_lat=data.pickup_lat,
        pickup_lng=data.pickup_lng,
        dropoff_address=data.dropoff_address,
        dropoff_lat=data.dropoff_lat,
        dropoff_lng=data.dropoff_lng,
        vehicle_type_id=vehicle_type_id,
        payment_method=data.payment_method,
    )
    ride = await RideService(db).create_ride(user.id, ride_data)
    await manager.broadcast_ride(str(ride.id), {"event": "ride_requested", "ride_id": str(ride.id), "status": ride.status})
    return _ride_summary(ride)


@router.get("/rides")
async def list_rides(
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    status: str | None = None,
):
    repo = RideRepository(db)
    rides = await repo.get_user_rides(user.id, page, page_size, status)
    active = await repo.get_active_ride_for_user(user.id)
    return {
        "active": _ride_summary(active) if active else None,
        "items": [_ride_summary(r) for r in rides],
        "page": page,
        "page_size": page_size,
    }


@router.get("/ride/{ride_id}")
async def get_ride(
    ride_id: UUID,
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    ride = await RideService(db).get_ride(ride_id)
    if ride.user_id != user.id:
        raise ForbiddenException("Access denied")
    response = RideDetailResponse.model_validate(ride)
    if ride.driver:
        response.driver = {
            "id": str(ride.driver.id),
            "name": f"{ride.driver.first_name} {ride.driver.last_name}",
            "phone": ride.driver.phone,
            "rating": ride.driver.rating_avg,
        }
    return response


@router.post("/cancel-ride")
async def cancel_ride(
    data: CancelRideRequest,
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    ride = await RideService(db).get_ride(data.ride_id)
    if ride.user_id != user.id:
        raise ForbiddenException("Access denied")
    ride = await RideService(db).cancel_ride(data.ride_id, "USER", data.reason)
    await manager.broadcast_ride(str(data.ride_id), {"event": "ride_cancelled", "ride_id": str(data.ride_id)})
    return RideResponse.model_validate(ride)


@router.get("/wallet")
async def get_wallet(user: Annotated[User, Depends(get_current_user)], db: AsyncSession = Depends(get_db)):
    wallet = await WalletService(db).get_or_create_wallet(user_id=user.id)
    return {
        "balance": wallet.balance,
        "bonus_balance": 0.0,
        "referral_balance": 0.0,
        "total": wallet.balance,
    }


@router.get("/transactions")
async def get_transactions(
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
):
    from app.models import WalletTransaction

    wallet = await WalletService(db).get_or_create_wallet(user_id=user.id)
    result = await db.execute(
        select(WalletTransaction)
        .where(WalletTransaction.wallet_id == wallet.id)
        .order_by(WalletTransaction.created_at.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    )
    return [WalletTransactionResponse.model_validate(t) for t in result.scalars().all()]


@router.post("/payment")
async def add_payment(
    data: PaymentRequest,
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    wallet = await WalletService(db).get_or_create_wallet(user_id=user.id)
    txn = await WalletService(db).credit(wallet.id, data.amount, data.description)
    wallet = await WalletService(db).get_or_create_wallet(user_id=user.id)
    return {"transaction": WalletTransactionResponse.model_validate(txn), "balance": wallet.balance}


@router.get("/notifications")
async def notifications(
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
):
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == user.id)
        .order_by(Notification.created_at.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    )
    return [{"id": str(n.id), "title": n.title, "body": n.message, "is_read": n.is_read} for n in result.scalars().all()]


@router.post("/support")
async def create_support(
    data: SupportRequest,
    user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    ticket = SupportTicket(
        user_id=user.id,
        subject=data.subject,
        description=data.message,
        status=SupportTicketStatus.OPEN.value,
        priority=SupportTicketPriority.MEDIUM.value,
    )
    db.add(ticket)
    await db.flush()
    return {"id": str(ticket.id), "subject": ticket.subject, "status": "open"}


@router.get("/dashboard")
async def user_dashboard(user: Annotated[User, Depends(get_current_user)], db: AsyncSession = Depends(get_db)):
    return await UserApiService(db).home_dashboard(user)


@router.get("/ride/{ride_id}/driver")
async def ride_driver(ride_id: UUID, user: Annotated[User, Depends(get_current_user)], db: AsyncSession = Depends(get_db)):
    ride = await RideService(db).get_ride(ride_id)
    if ride.user_id != user.id or not ride.driver:
        raise NotFoundException("Driver not assigned")
    driver = ride.driver
    return {
        "id": str(driver.id),
        "name": f"{driver.first_name} {driver.last_name}".strip(),
        "phone": format_phone_display(driver.phone),
        "rating": driver.rating_avg,
        "vehicle_number": ride.vehicle.license_plate if ride.vehicle else "",
        "photo_url": driver.profile_photo,
    }
