from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.user import User
from app.services.order_service import OrderService
from app.schemas.order import OrderCreate, OrderStatusUpdate
from app.dependencies.authentication import get_current_user

router = APIRouter(prefix="/api/orders", tags=["Orders"])


@router.get("", summary="Get user orders")
def list_orders(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role == "farmer":
        orders = OrderService.get_farmer_orders(db, current_user.id)
    else:
        orders = OrderService.get_customer_orders(db, current_user.id)
    return {"success": True, "count": len(orders), "orders": orders}


@router.post("", summary="Create order", status_code=status.HTTP_201_CREATED)
def create_order(
    data: OrderCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return OrderService.create_order(db, current_user.id, data)


@router.put("/{id}/status", summary="Update order status")
def update_status(
    id: int,
    data: OrderStatusUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return OrderService.update_order_status(db, id, data.status)
