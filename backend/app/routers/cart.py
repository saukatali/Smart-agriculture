from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.user import User
from app.services.order_service import OrderService
from app.schemas.cart import AddToCartRequest, UpdateCartRequest
from app.dependencies.authentication import get_current_user

router = APIRouter(prefix="/api/cart", tags=["Cart"])


@router.get("", summary="Get current user cart")
def get_cart(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return OrderService.get_cart(db, current_user.id)


@router.post("", summary="Add item to cart")
def add_to_cart(
    data: AddToCartRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return OrderService.add_to_cart(db, current_user.id, data.productId, data.quantity)


@router.put("/{id}", summary="Update item quantity in cart")
def update_cart(
    id: int,
    data: UpdateCartRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return OrderService.update_cart_item(db, current_user.id, id, data.quantity)


@router.delete("/{id}", summary="Delete item from cart")
def delete_cart_item(
    id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return OrderService.remove_from_cart(db, current_user.id, id)
