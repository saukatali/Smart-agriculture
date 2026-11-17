from sqlalchemy import Column, Integer, String, Text, Float, Boolean, DateTime, func
from app.database.base import Base

class DemandPrediction(Base):
    __tablename__ = "demand_predictions"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    cropName = Column(String(255), nullable=False)
    region = Column(String(255), nullable=True)
    demandScore = Column(Float, nullable=True)
    demandLevel = Column(String(50), nullable=True)
    predictedTrend = Column(String(50), nullable=True)
    projectedPrice = Column(String(255), nullable=True)
    trendPercentage = Column(String(50), nullable=True)
    tag = Column(String(100), default="High Demand")
    isHighDemand = Column(Boolean, default=False, nullable=False)
    imageType = Column(String(100), default="grain")
    forecastWindow = Column(String(50), default="7 Days", nullable=False, index=True)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

class SmartRecommendation(Base):
    __tablename__ = "smart_recommendations"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    title = Column(String(255), nullable=False)
    confidence = Column(String(100), nullable=False)
    description = Column(Text, nullable=False)
    profitIncrease = Column(String(50), nullable=False)
    actionLabel = Column(String(100), nullable=False)
    iconName = Column(String(100), default="inventory_2_outlined")
    isApplied = Column(Boolean, default=False, nullable=False)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

class SupplierCompliance(Base):
    __tablename__ = "supplier_compliances"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    supplierName = Column(String(255), nullable=False)
    certificationType = Column(String(255), nullable=False)
    status = Column(String(100), default="Valid", nullable=False)
    renewalDate = Column(String(100), nullable=False)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

class ModerationReport(Base):
    __tablename__ = "moderation_reports"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    reportType = Column(String(100), nullable=True)
    targetId = Column(Integer, nullable=True)
    targetTitle = Column(String(255), nullable=True)
    reportedBy = Column(Integer, nullable=True)
    reporterId = Column(Integer, nullable=True)
    userName = Column(String(255), nullable=True)
    reporterName = Column(String(255), nullable=True)
    userRole = Column(String(50), default="Farmer")
    reason = Column(Text, nullable=False)
    status = Column(String(100), default="Pending Review", nullable=False)
    notes = Column(Text, nullable=True)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

