from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from app.database.base import Base

class CustomerProfile(Base):
    __tablename__ = "customer_profiles"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    userId = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    name = Column(String(255), nullable=True)
    email = Column(String(255), nullable=True)
    mobile = Column(String(50), nullable=True)
    address = Column(Text, nullable=True)
    deliveryAddress = Column(Text, nullable=True)
    city = Column(String(100), nullable=True)
    state = Column(String(100), nullable=True)
    preferences = Column(Text, nullable=True)
    orderCount = Column(Integer, default=0, nullable=False)
    totalSpent = Column(Float, default=0.0, nullable=False)
    totalOrders = Column(Integer, default=0, nullable=False)
    profileImage = Column(Text, nullable=True)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

    user = relationship("User", back_populates="customer_profile")

