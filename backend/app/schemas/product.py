from typing import Optional
from datetime import datetime
from pydantic import BaseModel, Field

class CategoryResponse(BaseModel):
    id: int
    name: str
    slug: str
    icon: Optional[str] = "grain"
    description: Optional[str] = None

    class Config:
        from_attributes = True

class ProductBase(BaseModel):
    name: str = Field(..., min_length=2)
    categoryId: int = 1
    pricePerKg: float = Field(..., ge=0)
    availableQuantity: float = Field(..., ge=0)
    unit: str = "kg"
    qualityGrade: str = "Grade A"
    description: Optional[str] = ""
    location: Optional[str] = "Ahmedabad, Gujarat"
    primaryImage: Optional[str] = "grain"
    harvestDate: Optional[str] = None

class ProductCreate(ProductBase):
    pass

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    categoryId: Optional[int] = None
    pricePerKg: Optional[float] = None
    availableQuantity: Optional[float] = None
    unit: Optional[str] = None
    qualityGrade: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None
    isAvailable: Optional[bool] = None
    primaryImage: Optional[str] = None

class ProductResponse(ProductBase):
    id: int
    farmerId: int
    farmerName: Optional[str] = None
    farmName: Optional[str] = None
    farmRating: Optional[float] = 5.0
    categoryName: Optional[str] = None
    isAvailable: bool = True
    salesCount: int = 0
    rating: float = 5.0
    reviewCount: int = 0
    createdAt: Optional[datetime] = None

    class Config:
        from_attributes = True

