from sqlalchemy import Column, Integer, String, Float, DateTime, func
from app.database.base import Base

class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    orderId = Column(Integer, nullable=False, index=True)
    paymentId = Column(String(255), nullable=True)
    amount = Column(Float, nullable=False)
    currency = Column(String(10), default="INR")
    status = Column(String(50), default="pending", nullable=False)
    method = Column(String(50), default="COD")
    razorpayOrderId = Column(String(255), nullable=True)
    signature = Column(String(255), nullable=True)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

