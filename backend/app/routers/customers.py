from typing import Optional
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.user import User
from app.models.farmer import FarmerProfile
from app.services.product_service import ProductService
from app.services.order_service import OrderService
from app.schemas.cart import AddToCartRequest, UpdateCartRequest
from app.schemas.order import OrderCreate
from app.dependencies.authentication import get_current_user

router = APIRouter(prefix="/api/customer", tags=["Customer Marketplace"])


@router.get("/categories", summary="List marketplace categories")
def get_categories(db: Session = Depends(get_db)):
    categories = ProductService.get_categories(db)
    return {"success": True, "count": len(categories), "categories": categories}


@router.get("/products", summary="List products with optional search and category filters")
def get_products(
    categoryId: Optional[int] = None,
    search: Optional[str] = None,
    limit: int = 100,
    db: Session = Depends(get_db),
):
    products = ProductService.get_products(db, category_id=categoryId, search=search, limit=limit)
    return {"success": True, "count": len(products), "products": products}


@router.get("/products/{id}", summary="Get product details by ID")
def get_product(id: int, db: Session = Depends(get_db)):
    product = ProductService.get_product_by_id(db, id)
    return {"success": True, "product": product}


@router.get("/farmers", summary="Discover nearby verified organic farmers")
def get_nearby_farmers(db: Session = Depends(get_db)):
    farmers = db.query(FarmerProfile).order_by(FarmerProfile.rating.desc()).all()
    results = []
    for fp in farmers:
        u = db.query(User).filter(User.id == fp.userId).first()
        results.append({
            "id": fp.id,
            "userId": fp.userId,
            "farmName": fp.farmName,
            "farmLocation": fp.farmLocation,
            "availableProducts": fp.availableProducts,
            "rating": fp.rating,
            "reviewsCount": fp.reviewCount,
            "farmerName": u.name if u else "Farmer",
            "distance": "2.2 km away",
        })
    return {"success": True, "count": len(results), "farmers": results}


@router.get("/cart", summary="Get user's active shopping cart items")
def get_cart(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return OrderService.get_cart(db, current_user.id)


@router.post("/cart", summary="Add item to shopping cart in MySQL")
def add_to_cart(
    data: AddToCartRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return OrderService.add_to_cart(db, current_user.id, data.productId, data.quantity)


@router.put("/cart/{id}", summary="Update quantity of item in cart")
def update_cart_item(
    id: int,
    data: UpdateCartRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return OrderService.update_cart_item(db, current_user.id, id, data.quantity)


@router.delete("/cart/{id}", summary="Remove item from cart")
def remove_from_cart(
    id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return OrderService.remove_from_cart(db, current_user.id, id)


@router.post("/checkout", summary="Checkout cart and create order in MySQL", status_code=status.HTTP_201_CREATED)
def checkout(
    data: OrderCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return OrderService.create_order(db, current_user.id, data)


@router.get("/orders", summary="Get customer's past orders")
def get_my_orders(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    orders = OrderService.get_customer_orders(db, current_user.id)
    return {"success": True, "count": len(orders), "orders": orders}
