from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.user import User
from app.services.product_service import ProductService
from app.services.order_service import OrderService
from app.services.insight_service import InsightService
from app.schemas.product import ProductCreate, ProductUpdate
from app.schemas.order import OrderStatusUpdate
from app.dependencies.authentication import get_current_user, require_role

router = APIRouter(prefix="/api/farmer", tags=["Farmer Operations"])


@router.get("/dashboard", summary="Get farmer dashboard KPI statistics, sales history, and active products")
def get_farmer_dashboard(
    current_user: User = Depends(require_role(["farmer"])),
    db: Session = Depends(get_db),
):
    return InsightService.get_farmer_dashboard(db, current_user.id)


@router.get("/sales-history", summary="Get weekly sales performance history (Mon-Sun)")
def get_sales_history(
    current_user: User = Depends(require_role(["farmer"])),
    db: Session = Depends(get_db),
):
    dashboard = InsightService.get_farmer_dashboard(db, current_user.id)
    return {"success": True, "history": dashboard.get("salesHistory", [])}


@router.get("/products", summary="List products listed by this farmer")
def get_farmer_products(
    current_user: User = Depends(require_role(["farmer"])),
    db: Session = Depends(get_db),
):
    products = ProductService.get_products(db, farmer_id=current_user.id)
    return {"success": True, "count": len(products), "products": products}


@router.post("/products", summary="Publish new agricultural product listing to MySQL", status_code=status.HTTP_201_CREATED)
def add_farmer_product(
    data: ProductCreate,
    current_user: User = Depends(require_role(["farmer"])),
    db: Session = Depends(get_db),
):
    product = ProductService.create_product(db, current_user.id, data)
    return {"success": True, "message": "Product listing created successfully!", "product": product}


@router.put("/products/{id}", summary="Update existing product listing")
def update_farmer_product(
    id: int,
    data: ProductUpdate,
    current_user: User = Depends(require_role(["farmer"])),
    db: Session = Depends(get_db),
):
    product = ProductService.update_product(db, id, data)
    return {"success": True, "message": "Product updated successfully!", "product": product}


@router.delete("/products/{id}", summary="Delete product listing")
def delete_farmer_product(
    id: int,
    current_user: User = Depends(require_role(["farmer"])),
    db: Session = Depends(get_db),
):
    deleted = ProductService.delete_product(db, id)
    return {"success": deleted, "message": "Product deleted successfully."}


@router.get("/orders", summary="Get orders placed with this farmer")
def get_farmer_orders(
    current_user: User = Depends(require_role(["farmer"])),
    db: Session = Depends(get_db),
):
    orders = OrderService.get_farmer_orders(db, current_user.id)
    return {"success": True, "count": len(orders), "orders": orders}


@router.put("/orders/{id}/status", summary="Update order lifecycle status (pending -> confirmed -> shipped -> delivered)")
def update_farmer_order_status(
    id: int,
    data: OrderStatusUpdate,
    current_user: User = Depends(require_role(["farmer"])),
    db: Session = Depends(get_db),
):
    return OrderService.update_order_status(db, id, data.status)
