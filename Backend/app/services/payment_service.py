from abc import ABC, abstractmethod
from typing import Optional
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.constants import PaymentMethod, PaymentStatus, WalletTransactionType
from app.core.exceptions import PaymentException, ValidationException
from app.models import Payment, Wallet, WalletTransaction
from app.repositories.admin_repository import WalletRepository


class PaymentGateway(ABC):
    @abstractmethod
    async def create_payment(self, amount: float, currency: str, metadata: dict) -> dict:
        pass

    @abstractmethod
    async def verify_payment(self, transaction_id: str) -> dict:
        pass

    @abstractmethod
    async def refund_payment(self, transaction_id: str, amount: float) -> dict:
        pass


class CashGateway(PaymentGateway):
    async def create_payment(self, amount: float, currency: str, metadata: dict) -> dict:
        return {"status": "completed", "transaction_id": f"cash_{metadata.get('ride_id')}"}

    async def verify_payment(self, transaction_id: str) -> dict:
        return {"status": "completed", "transaction_id": transaction_id}

    async def refund_payment(self, transaction_id: str, amount: float) -> dict:
        return {"status": "refunded", "amount": amount}


class WalletGateway(PaymentGateway):
    def __init__(self, db: AsyncSession):
        self.db = db
        self.wallet_repo = WalletRepository(db)

    async def create_payment(self, amount: float, currency: str, metadata: dict) -> dict:
        user_id = metadata.get("user_id")
        wallet = await self.wallet_repo.get_by_user_id(UUID(str(user_id)))
        if not wallet or wallet.balance < amount:
            raise PaymentException("Insufficient wallet balance")

        wallet.balance -= amount
        txn = WalletTransaction(
            wallet_id=wallet.id,
            transaction_type=WalletTransactionType.DEBIT.value,
            amount=amount,
            balance_before=wallet.balance + amount,
            balance_after=wallet.balance,
            description=f"Ride payment {metadata.get('ride_id')}",
            reference_id=str(metadata.get("ride_id")),
            reference_type="RIDE",
        )
        self.db.add(txn)
        await self.wallet_repo.update(wallet)
        return {"status": "completed", "transaction_id": str(txn.id)}

    async def verify_payment(self, transaction_id: str) -> dict:
        return {"status": "completed", "transaction_id": transaction_id}

    async def refund_payment(self, transaction_id: str, amount: float) -> dict:
        return {"status": "refunded", "amount": amount}


class StripeGateway(PaymentGateway):
    async def create_payment(self, amount: float, currency: str, metadata: dict) -> dict:
        return {"status": "pending", "client_secret": "stripe_client_secret", "transaction_id": "stripe_pending"}

    async def verify_payment(self, transaction_id: str) -> dict:
        return {"status": "completed", "transaction_id": transaction_id}

    async def refund_payment(self, transaction_id: str, amount: float) -> dict:
        return {"status": "refunded", "amount": amount}


class RazorpayGateway(PaymentGateway):
    async def create_payment(self, amount: float, currency: str, metadata: dict) -> dict:
        return {"status": "pending", "order_id": "razorpay_order_id", "transaction_id": "razorpay_pending"}

    async def verify_payment(self, transaction_id: str) -> dict:
        return {"status": "completed", "transaction_id": transaction_id}

    async def refund_payment(self, transaction_id: str, amount: float) -> dict:
        return {"status": "refunded", "amount": amount}


class PaymentService:
    GATEWAYS = {
        PaymentMethod.CASH.value: CashGateway,
        PaymentMethod.WALLET.value: WalletGateway,
        PaymentMethod.STRIPE.value: StripeGateway,
        PaymentMethod.RAZORPAY.value: RazorpayGateway,
        PaymentMethod.UPI.value: RazorpayGateway,
        PaymentMethod.CARD.value: StripeGateway,
        PaymentMethod.CASHFREE.value: RazorpayGateway,
        PaymentMethod.PHONEPE.value: RazorpayGateway,
    }

    def __init__(self, db: AsyncSession):
        self.db = db

    def _get_gateway(self, method: str) -> PaymentGateway:
        gateway_class = self.GATEWAYS.get(method)
        if not gateway_class:
            raise ValidationException(f"Unsupported payment method: {method}")
        if gateway_class == WalletGateway:
            return gateway_class(self.db)
        return gateway_class()

    async def process_payment(
        self,
        ride_id: UUID,
        user_id: UUID,
        amount: float,
        payment_method: str,
    ) -> Payment:
        gateway = self._get_gateway(payment_method)
        result = await gateway.create_payment(
            amount, "INR", {"ride_id": str(ride_id), "user_id": str(user_id)}
        )

        payment = Payment(
            ride_id=ride_id,
            user_id=user_id,
            amount=amount,
            payment_method=payment_method,
            status=PaymentStatus.COMPLETED.value if result["status"] == "completed" else PaymentStatus.PENDING.value,
            gateway_transaction_id=result.get("transaction_id"),
            gateway_response=result,
        )
        self.db.add(payment)
        await self.db.flush()
        await self.db.refresh(payment)
        return payment


class WalletService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.wallet_repo = WalletRepository(db)

    async def get_or_create_wallet(self, user_id: Optional[UUID] = None, driver_id: Optional[UUID] = None) -> Wallet:
        if user_id:
            wallet = await self.wallet_repo.get_by_user_id(user_id)
            if not wallet:
                wallet = Wallet(user_id=user_id, balance=0.0)
                await self.wallet_repo.create(wallet)
            return wallet
        if driver_id:
            wallet = await self.wallet_repo.get_by_driver_id(driver_id)
            if not wallet:
                wallet = Wallet(driver_id=driver_id, balance=0.0)
                await self.wallet_repo.create(wallet)
            return wallet
        raise ValidationException("User or driver ID required")

    async def credit(
        self, wallet_id: UUID, amount: float, description: str, reference_id: Optional[str] = None
    ) -> WalletTransaction:
        wallet = await self.wallet_repo.get_by_id(wallet_id)
        if not wallet:
            raise ValidationException("Wallet not found")

        balance_before = wallet.balance
        wallet.balance += amount
        txn = WalletTransaction(
            wallet_id=wallet_id,
            transaction_type=WalletTransactionType.CREDIT.value,
            amount=amount,
            balance_before=balance_before,
            balance_after=wallet.balance,
            description=description,
            reference_id=reference_id,
        )
        self.db.add(txn)
        await self.wallet_repo.update(wallet)
        await self.db.flush()
        await self.db.refresh(txn)
        return txn
