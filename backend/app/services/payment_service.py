from sqlalchemy.orm import Session
from app.models.payment import Payment

class PaymentService:
    @staticmethod
    def record_payment(db: Session, order_id: int, amount: float, method: str = "COD") -> Payment:
        payment = Payment(
            orderId=order_id,
            amount=amount,
            currency="INR",
            status="completed" if method != "COD" else "pending",
            method=method,
        )
        db.add(payment)
        db.commit()
        db.refresh(payment)
        return payment

