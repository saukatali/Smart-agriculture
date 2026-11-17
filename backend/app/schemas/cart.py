from typing import Optional
from datetime import datetime
from pydantic import BaseModel, Field

class AddToCartRequest(BaseModel):
    productId: int
    quantity: float = Field(1.0, gt=0)

class UpdateCartRequest(BaseModel):
    quantity: float = Field(..., ge=0)

class CartItemResponse(BaseModel):
    id: int
    userId: int
    productId: int
    quantity: float
    price: float
    productName: Optional[str] = None
    unit: Optional[str] = "kg"
    primaryImage: Optional[str] = "grain"
    location: Optional[str] = None
    farmerName: Optional[str] = None
    farmerId: Optional[int] = None
    createdAt: Optional[datetime] = None

    class Config:
        from_attributes = True

class CartResponse(BaseModel):
    success: bool = True
    count: int = 0
    items: list[CartItemResponse] = []
    totalAmount: float = 0.0

