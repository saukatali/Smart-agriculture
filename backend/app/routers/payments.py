from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.database.connection import get_db
from app.models.user import User
from app.services.payment_service import PaymentService
from app.dependencies.authentication import get_current_user

router = APIRouter(prefix="/api/payments", tags=["Payments"])


class PaymentRecordRequest(BaseModel):
    orderId: int
    amount: float
    method: str = "COD"


@router.post("/record", summary="Record order payment")
def record_payment(
    data: PaymentRecordRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    payment = PaymentService.record_payment(db, data.orderId, data.amount, data.method)
    return {"success": True, "message": "Payment recorded", "paymentId": payment.id}
