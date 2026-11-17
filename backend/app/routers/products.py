from typing import Optional
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.services.product_service import ProductService

router = APIRouter(prefix="/api/products", tags=["Products"])

@router.get("", summary="Get all marketplace products")
def list_products(
    categoryId: Optional[int] = None,
    search: Optional[str] = None,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    products = ProductService.get_products(db, category_id=categoryId, search=search, limit=limit)
    return {"success": True, "count": len(products), "products": products}

@router.get("/{id}", summary="Get product details")
def get_product(id: int, db: Session = Depends(get_db)):
    product = ProductService.get_product_by_id(db, id)
    return {"success": True, "product": product}

