"""Driver Panel API — /api/v1/driver/*"""
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.driver.dependencies import get_current_driver
from app.core.constants import DriverStatus, KYCStatus, RideStatus
from app.core.exceptions import ForbiddenException, NotFoundException
from app.database.session import get_db
from app.models import Driver, DriverDocument, Ride, Vehicle
from app.repositories.driver_repository import DriverRepository
from app.repositories.ride_repository import RideRepository
from app.schemas.driver import (
    DriverDocumentCreate,
    DriverEarningsResponse,
    DriverLocationUpdate,
    DriverRegistrationComplete,
    DriverResponse,
    DriverUpdate,
    DriverVehicleCreate,
)
from app.services.driver_registration_service import DriverRegistrationService
from app.schemas.ride import RideOTPVerify, RideResponse
from app.services.driver_matching import DriverMatchingService
from app.services.payment_service import PaymentService
from app.services.ride_service import RideService
from app.api.websocket.manager import manager

router = APIRouter(tags=["Driver"])


class AcceptRideRequest(BaseModel):
    ride_id: UUID
    vehicle_id: UUID


class RejectRideRequest(BaseModel):
    ride_id: UUID
    reason: str | None = None


class StartRideRequest(BaseModel):
    ride_id: UUID
    otp: str


class EndRideRequest(BaseModel):
    ride_id: UUID


@router.get("/profile", response_model=DriverResponse)
async def get_profile(driver: Annotated[Driver, Depends(get_current_driver)]):
    return DriverResponse.model_validate(driver)


@router.put("/profile", response_model=DriverResponse)
async def update_profile(
    data: DriverUpdate,
    driver: Annotated[Driver, Depends(get_current_driver)],
    db: AsyncSession = Depends(get_db),
):
    repo = DriverRepository(db)
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(driver, field, value)
    await repo.update(driver)
    return DriverResponse.model_validate(driver)


@router.post("/upload-license")
async def upload_license(
    data: DriverDocumentCreate,
    driver: Annotated[Driver, Depends(get_current_driver)],
    db: AsyncSession = Depends(get_db),
):
    doc = DriverDocument(
        driver_id=driver.id,
        document_type="DRIVING_LICENSE",
        document_url=data.document_url,
        document_number=data.document_number,
        status="PENDING",
    )
    db.add(doc)
    await db.flush()
    return {"id": str(doc.id), "status": doc.status}


@router.post("/upload-vehicle")
async def upload_vehicle(
    data: DriverVehicleCreate,
    driver: Annotated[Driver, Depends(get_current_driver)],
    db: AsyncSession = Depends(get_db),
):
    vehicle = Vehicle(
        driver_id=driver.id,
        vehicle_type_id=data.vehicle_type_id,
        license_plate=data.license_plate,
        make=data.make or data.model,
        model=data.model,
        color=data.color,
        year=data.year,
    )
    db.add(vehicle)
    await db.flush()
    return {"id": str(vehicle.id), "license_plate": vehicle.license_plate}


@router.post("/complete-registration")
async def complete_registration(
    data: DriverRegistrationComplete,
    driver: Annotated[Driver, Depends(get_current_driver)],
    db: AsyncSession = Depends(get_db),
):
    return await DriverRegistrationService(db).complete_registration(driver, data)


@router.put("/go-online")
async def go_online(driver: Annotated[Driver, Depends(get_current_driver)], db: AsyncSession = Depends(get_db)):
    if driver.kyc_status != KYCStatus.APPROVED.value:
        if driver.kyc_status == KYCStatus.REJECTED.value:
            raise ForbiddenException(
                "Your documents were rejected. Please update and resubmit before going online."
            )
        raise ForbiddenException(
            "Account verification is pending. You can go online after admin approval."
        )
    if not driver.is_verified:
        raise ForbiddenException(
            "Phone verification is required before going online."
        )

    driver.status = DriverStatus.ONLINE.value
    await DriverRepository(db).update(driver)
    matching = DriverMatchingService(db)
    lat, lng = await matching.driver_default_location(driver.id)
    await matching.ensure_driver_online(driver, lat, lng)
    return {"status": driver.status}


@router.put("/go-offline")
async def go_offline(driver: Annotated[Driver, Depends(get_current_driver)], db: AsyncSession = Depends(get_db)):
    driver.status = DriverStatus.OFFLINE.value
    await DriverRepository(db).update(driver)
    await DriverMatchingService(db).set_driver_offline(driver.id)
    return {"status": driver.status}


@router.post("/location")
async def update_location(
    data: DriverLocationUpdate,
    driver: Annotated[Driver, Depends(get_current_driver)],
    db: AsyncSession = Depends(get_db),
):
    await DriverMatchingService(db).update_driver_location(driver.id, data.lat, data.lng, data.heading, data.speed)
    if driver.status == DriverStatus.ONLINE.value:
        await DriverMatchingService(db).ensure_driver_online(driver, data.lat, data.lng)
    return {"message": "Location updated"}


@router.get("/ride-requests")
async def ride_requests(driver: Annotated[Driver, Depends(get_current_driver)], db: AsyncSession = Depends(get_db)):
    from sqlalchemy.orm import selectinload

    matching = DriverMatchingService(db)
    pending_ids = await matching.get_pending_ride_ids(driver.id)

    query = select(Ride).options(selectinload(Ride.user))
    if pending_ids:
        query = query.where(
            Ride.id.in_(pending_ids),
            Ride.status == RideStatus.SEARCHING_DRIVER.value,
        )
    else:
        query = query.where(
            Ride.status.in_([RideStatus.REQUESTED.value, RideStatus.SEARCHING_DRIVER.value])
        )
    query = query.order_by(Ride.created_at.desc()).limit(20)

    result = await db.execute(query)
    return [
        {
            "id": str(r.id),
            "pickup_address": r.pickup_address,
            "dropoff_address": r.dropoff_address,
            "pickup_lat": r.pickup_lat,
            "pickup_lng": r.pickup_lng,
            "dropoff_lat": r.dropoff_lat,
            "dropoff_lng": r.dropoff_lng,
            "estimated_fare": r.estimated_fare,
            "estimated_distance_km": r.estimated_distance_km,
            "estimated_duration_min": r.estimated_duration_min,
            "payment_method": r.payment_method,
            "passenger_name": (
                f"{r.user.first_name} {r.user.last_name}".strip() if r.user else "Passenger"
            ),
            "passenger_phone": r.user.phone if r.user else None,
            "status": r.status,
            "created_at": r.created_at.isoformat(),
        }
        for r in result.scalars().all()
    ]


@router.post("/accept-ride", response_model=RideResponse)
async def accept_ride(
    data: AcceptRideRequest,
    driver: Annotated[Driver, Depends(get_current_driver)],
    db: AsyncSession = Depends(get_db),
):
    ride = await RideService(db).accept_ride(data.ride_id, driver.id, data.vehicle_id)
    await DriverMatchingService(db).clear_driver_pending(driver.id, data.ride_id)
    await manager.broadcast_ride(str(data.ride_id), {"event": "ride_accepted", "ride_id": str(data.ride_id), "driver_id": str(driver.id)})
    return RideResponse.model_validate(ride)


@router.post("/reject-ride")
async def reject_ride(
    data: RejectRideRequest,
    driver: Annotated[Driver, Depends(get_current_driver)],
    db: AsyncSession = Depends(get_db),
):
    await DriverMatchingService(db).clear_driver_pending(driver.id, data.ride_id)
    return {"ride_id": str(data.ride_id), "status": "rejected", "reason": data.reason}


@router.post("/start-ride", response_model=RideResponse)
async def start_ride(
    data: StartRideRequest,
    driver: Annotated[Driver, Depends(get_current_driver)],
    db: AsyncSession = Depends(get_db),
):
    ride = await RideService(db).get_ride(data.ride_id)
    if ride.driver_id != driver.id:
        raise ForbiddenException("Access denied")
    ride = await RideService(db).verify_otp_and_start(data.ride_id, data.otp)
    await manager.broadcast_ride(str(data.ride_id), {"event": "ride_started", "ride_id": str(data.ride_id)})
    return RideResponse.model_validate(ride)


@router.post("/end-ride", response_model=RideResponse)
async def end_ride(
    data: EndRideRequest,
    driver: Annotated[Driver, Depends(get_current_driver)],
    db: AsyncSession = Depends(get_db),
):
    ride = await RideService(db).get_ride(data.ride_id)
    if ride.driver_id != driver.id:
        raise ForbiddenException("Access denied")
    ride = await RideService(db).complete_ride(data.ride_id)
    if ride.final_fare:
        await PaymentService(db).process_payment(ride.id, ride.user_id, ride.final_fare, ride.payment_method)
    await manager.broadcast_ride(str(data.ride_id), {"event": "ride_completed", "ride_id": str(data.ride_id)})
    return RideResponse.model_validate(ride)


@router.get("/wallet")
async def driver_wallet(driver: Annotated[Driver, Depends(get_current_driver)], db: AsyncSession = Depends(get_db)):
    from app.services.payment_service import WalletService

    wallet = await WalletService(db).get_or_create_wallet(driver_id=driver.id)
    return {"balance": wallet.balance}


@router.get("/earnings", response_model=DriverEarningsResponse)
async def earnings(driver: Annotated[Driver, Depends(get_current_driver)], period: str = Query("daily")):
    return DriverEarningsResponse(
        period=period,
        total_rides=driver.total_rides,
        total_earnings=0.0,
        net_earnings=0.0,
    )


@router.get("/active-ride")
async def active_ride(driver: Annotated[Driver, Depends(get_current_driver)], db: AsyncSession = Depends(get_db)):
    ride = await RideRepository(db).get_active_ride_for_driver(driver.id)
    return RideResponse.model_validate(ride) if ride else None


@router.get("/ride-history")
async def ride_history(
    driver: Annotated[Driver, Depends(get_current_driver)],
    db: AsyncSession = Depends(get_db),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
):
    repo = RideRepository(db)
    rides = await repo.get_driver_rides(driver.id, page, page_size)
    total = await repo.count([Ride.driver_id == driver.id])
    return {
        "items": [RideResponse.model_validate(r) for r in rides],
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": max(1, (total + page_size - 1) // page_size),
    }


class ArrivedRideRequest(BaseModel):
    ride_id: UUID


@router.post("/arrived-ride", response_model=RideResponse)
async def arrived_ride(
    data: ArrivedRideRequest,
    driver: Annotated[Driver, Depends(get_current_driver)],
    db: AsyncSession = Depends(get_db),
):
    ride = await RideService(db).get_ride(data.ride_id)
    if ride.driver_id != driver.id:
        raise ForbiddenException("Access denied")
    ride = await RideService(db).driver_arrived(data.ride_id)
    await manager.broadcast_ride(str(data.ride_id), {"event": "driver_arrived", "ride_id": str(data.ride_id)})
    return RideResponse.model_validate(ride)
