from typing import Optional
from datetime import datetime
from pydantic import BaseModel, Field

class DemandPredictionResponse(BaseModel):
    id: int
    cropName: str
    region: Optional[str] = None
    demandScore: Optional[float] = None
    demandLevel: Optional[str] = None
    projectedPrice: Optional[str] = None
    trendPercentage: Optional[str] = None
    tag: str = "High Demand"
    isHighDemand: bool = False
    imageType: str = "grain"
    forecastWindow: str = "7 Days"

    class Config:
        from_attributes = True

class SmartRecommendationResponse(BaseModel):
    id: int
    title: str
    confidence: str
    description: str
    profitIncrease: str
    actionLabel: str
    iconName: str = "inventory_2_outlined"
    isApplied: bool = False

    class Config:
        from_attributes = True

class SupplierComplianceResponse(BaseModel):
    id: int
    supplierName: str
    certificationType: str
    status: str
    renewalDate: str

    class Config:
        from_attributes = True

class ModerationReportResponse(BaseModel):
    id: int
    userName: Optional[str] = None
    userRole: Optional[str] = "Farmer"
    reason: str
    status: str = "Pending Review"
    createdAt: Optional[datetime] = None

    class Config:
        from_attributes = True

class BroadcastAlertRequest(BaseModel):
    title: str = Field(..., min_length=2)
    message: str = Field(..., min_length=5)

