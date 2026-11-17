from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from app.database.base import Base

class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    orderNumber = Column(String(100), unique=True, nullable=False, index=True)
    customerId = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    farmerId = Column(Integer, nullable=True, index=True)
    totalAmount = Column(Float, default=0.0, nullable=False)
    status = Column(String(50), default="pending", nullable=False, index=True)
    deliveryAddress = Column(Text, nullable=True)
    paymentMethod = Column(String(100), default="COD")
    paymentStatus = Column(String(50), default="pending", nullable=False)
    itemsJson = Text(collation="utf8mb4_unicode_ci")
    customerName = Column(String(255), nullable=True)
    customerMobile = Column(String(50), nullable=True)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

    customer = relationship("User", back_populates="orders", foreign_keys=[customerId])
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")

class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    orderId = Column(Integer, ForeignKey("orders.id", ondelete="CASCADE"), nullable=False, index=True)
    productId = Column(Integer, nullable=True)
    productName = Column(String(255), nullable=False)
    quantity = Column(Float, default=1.0, nullable=False)
    unitPrice = Column(Float, default=0.0, nullable=False)
    subtotal = Column(Float, default=0.0, nullable=False)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

    order = relationship("Order", back_populates="items")

