from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.services.product_service import ProductService

router = APIRouter(prefix="/api/categories", tags=["Categories"])

@router.get("", summary="List all product categories")
def list_categories(db: Session = Depends(get_db)):
    categories = ProductService.get_categories(db)
    return {"success": True, "count": len(categories), "categories": categories}

