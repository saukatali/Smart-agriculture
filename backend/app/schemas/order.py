from typing import Optional, Any
from datetime import datetime
from pydantic import BaseModel, Field

class OrderItemCreate(BaseModel):
    productId: Optional[int] = None
    productName: str
    quantity: float = Field(..., gt=0)
    price: float = Field(..., ge=0)

class OrderCreate(BaseModel):
    deliveryAddress: str = "Flat 402, Shivalik Residency, Ahmedabad, Gujarat"
    paymentMethod: str = "COD"
    customerName: Optional[str] = "Priya Sharma"
    customerMobile: Optional[str] = "+91 98765 43212"
    directItem: Optional[dict[str, Any]] = None

class OrderStatusUpdate(BaseModel):
    status: str = Field(..., pattern="^(pending|confirmed|processing|shipped|delivered|cancelled|rejected)$")

class OrderItemResponse(BaseModel):
    id: int
    productId: Optional[int] = None
    productName: str
    quantity: float
    unitPrice: float
    subtotal: float

    class Config:
        from_attributes = True

class OrderResponse(BaseModel):
    id: int
    orderNumber: str
    customerId: int
    farmerId: Optional[int] = None
    totalAmount: float
    status: str
    deliveryAddress: Optional[str] = None
    paymentMethod: Optional[str] = "COD"
    paymentStatus: str
    customerName: Optional[str] = None
    customerMobile: Optional[str] = None
    createdAt: Optional[datetime] = None
    items: list[OrderItemResponse] = []

    class Config:
        from_attributes = True

