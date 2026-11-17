from sqlalchemy import Column, Integer, String, Text, Float, Boolean, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from app.database.base import Base

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    farmerId = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    categoryId = Column(Integer, ForeignKey("categories.id", ondelete="RESTRICT"), nullable=False, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    pricePerKg = Column(Float, default=0.0, nullable=False)
    availableQuantity = Column(Float, default=0.0, nullable=False)
    unit = Column(String(50), default="kg", nullable=False)
    qualityGrade = Column(String(100), default="Grade A", nullable=False)
    harvestDate = Column(String(50), nullable=True)
    location = Column(String(255), default="Ahmedabad, Gujarat")
    isAvailable = Column(Boolean, default=True, nullable=False, index=True)
    views = Column(Integer, default=0, nullable=False)
    salesCount = Column(Integer, default=0, nullable=False)
    rating = Column(Float, default=5.0, nullable=False)
    reviewCount = Column(Integer, default=0, nullable=False)
    primaryImage = Column(Text, nullable=True)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

    farmer = relationship("User", back_populates="products")
    category = relationship("Category", back_populates="products")
    images = relationship("ProductImage", back_populates="product", cascade="all, delete-orphan")
    cart_items = relationship("CartItem", back_populates="product", cascade="all, delete-orphan")

class ProductImage(Base):
    __tablename__ = "product_images"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    productId = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False, index=True)
    imageUrl = Column(Text, nullable=False)
    isPrimary = Column(Boolean, default=False, nullable=False)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

    product = relationship("Product", back_populates="images")

