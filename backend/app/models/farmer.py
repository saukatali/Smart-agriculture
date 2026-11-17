from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from app.database.base import Base

class FarmerProfile(Base):
    __tablename__ = "farmer_profiles"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    userId = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    farmName = Column(String(255), nullable=False)
    farmLocation = Column(String(255), nullable=False)
    availableProducts = Column(Text, nullable=True)
    farmingExperience = Column(Integer, default=5)
    verificationStatus = Column(String(50), default="verified", nullable=False)
    rating = Column(Float, default=5.0, nullable=False)
    reviewCount = Column(Integer, default=0, nullable=False)
    totalSalesKg = Column(Float, default=0.0, nullable=False)
    profileImage = Column(Text, nullable=True)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

    user = relationship("User", back_populates="farmer_profile")

class SalesHistory(Base):
    __tablename__ = "sales_history"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    farmerId = Column(Integer, nullable=False, index=True)
    productId = Column(Integer, nullable=True)
    quantityKg = Column(Float, nullable=True)
    totalRevenue = Column(Float, nullable=True)
    day = Column(String(20), nullable=True)
    value = Column(Float, default=0.0, nullable=False)
    label = Column(String(50), nullable=True)
    saleDate = Column(DateTime, nullable=True)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

