from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import or_
from fastapi import HTTPException, status

from app.models.product import Product
from app.models.category import Category
from app.models.farmer import FarmerProfile
from app.models.user import User
from app.schemas.product import ProductCreate, ProductUpdate

class ProductService:
    @staticmethod
    def get_products(
        db: Session,
        category_id: Optional[int] = None,
        search: Optional[str] = None,
        farmer_id: Optional[int] = None,
        is_available: Optional[bool] = None,
        limit: int = 100
    ) -> list[dict]:
        query = db.query(Product)

        if is_available is not None:
            query = query.filter(Product.isAvailable == is_available)

        if category_id:
            query = query.filter(Product.categoryId == category_id)

        if farmer_id:
            query = query.filter(Product.farmerId == farmer_id)

        if search and search.strip():
            term = f"%{search.strip()}%"
            query = query.filter(
                or_(
                    Product.name.ilike(term),
                    Product.description.ilike(term),
                    Product.location.ilike(term),
                )
            )

        products = query.order_by(Product.id.desc()).limit(limit).all()

        results = []
        for p in products:
            farmer_profile = db.query(FarmerProfile).filter(FarmerProfile.userId == p.farmerId).first()
            farmer_user = db.query(User).filter(User.id == p.farmerId).first()
            category = db.query(Category).filter(Category.id == p.categoryId).first()

            results.append({
                "id": p.id,
                "farmerId": p.farmerId,
                "categoryId": p.categoryId,
                "name": p.name,
                "description": p.description or "",
                "pricePerKg": p.pricePerKg,
                "availableQuantity": p.availableQuantity,
                "unit": p.unit,
                "qualityGrade": p.qualityGrade,
                "harvestDate": p.harvestDate,
                "location": p.location,
                "isAvailable": p.isAvailable,
                "views": p.views,
                "salesCount": p.salesCount,
                "rating": p.rating,
                "reviewCount": p.reviewCount,
                "primaryImage": p.primaryImage or "grain",
                "farmerName": farmer_user.name if farmer_user else "Local Farmer",
                "farmName": farmer_profile.farmName if farmer_profile else "Local Farm",
                "farmRating": farmer_profile.rating if farmer_profile else 5.0,
                "categoryName": category.name if category else "General",
                "createdAt": p.createdAt,
            })

        return results

    @staticmethod
    def get_product_by_id(db: Session, product_id: int) -> dict:
        p = db.query(Product).filter(Product.id == product_id).first()
        if not p:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")

        farmer_profile = db.query(FarmerProfile).filter(FarmerProfile.userId == p.farmerId).first()
        farmer_user = db.query(User).filter(User.id == p.farmerId).first()
        category = db.query(Category).filter(Category.id == p.categoryId).first()

        return {
            "id": p.id,
            "farmerId": p.farmerId,
            "categoryId": p.categoryId,
            "name": p.name,
            "description": p.description or "",
            "pricePerKg": p.pricePerKg,
            "availableQuantity": p.availableQuantity,
            "unit": p.unit,
            "qualityGrade": p.qualityGrade,
            "harvestDate": p.harvestDate,
            "location": p.location,
            "isAvailable": p.isAvailable,
            "salesCount": p.salesCount,
            "rating": p.rating,
            "reviewCount": p.reviewCount,
            "primaryImage": p.primaryImage or "grain",
            "farmerName": farmer_user.name if farmer_user else "Local Farmer",
            "farmName": farmer_profile.farmName if farmer_profile else "Local Farm",
            "farmRating": farmer_profile.rating if farmer_profile else 5.0,
            "categoryName": category.name if category else "General",
        }

    @staticmethod
    def create_product(db: Session, farmer_id: int, data: ProductCreate) -> dict:
        new_prod = Product(
            farmerId=farmer_id,
            categoryId=data.categoryId,
            name=data.name.strip(),
            description=data.description or "",
            pricePerKg=data.pricePerKg,
            availableQuantity=data.availableQuantity,
            unit=data.unit,
            qualityGrade=data.qualityGrade,
            location=data.location or "Ahmedabad, Gujarat",
            primaryImage=data.primaryImage or "grain",
            harvestDate=data.harvestDate,
            isAvailable=True,
        )
        db.add(new_prod)
        db.commit()
        db.refresh(new_prod)
        return ProductService.get_product_by_id(db, new_prod.id)

    @staticmethod
    def update_product(db: Session, product_id: int, data: ProductUpdate) -> dict:
        prod = db.query(Product).filter(Product.id == product_id).first()
        if not prod:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")

        for key, val in data.model_dump(exclude_unset=True).items():
            setattr(prod, key, val)

        db.commit()
        db.refresh(prod)
        return ProductService.get_product_by_id(db, prod.id)

    @staticmethod
    def delete_product(db: Session, product_id: int) -> bool:
        prod = db.query(Product).filter(Product.id == product_id).first()
        if not prod:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
        db.delete(prod)
        db.commit()
        return True

    @staticmethod
    def get_categories(db: Session) -> list[Category]:
        return db.query(Category).order_by(Category.id.asc()).all()

