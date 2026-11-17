from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from app.database.base import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column("full_name", String(255), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    phone = Column(String(50), nullable=True)
    password = Column("password_hash", String(255), nullable=False)
    role = Column(String(50), nullable=False, default="customer", index=True)
    mobile = Column(String(50), nullable=True)
    location = Column(String(255), default="Ahmedabad, Gujarat")
    city = Column(String(100), default="Ahmedabad")
    state = Column(String(100), default="Gujarat")
    address = Column(Text, nullable=True)
    avatar = Column(Text, nullable=True)
    profileImage = Column(Text, nullable=True)
    status = Column(String(50), default="active", nullable=False)
    isVerified = Column(Boolean, default=True)
    createdAt = Column("created_at", DateTime, server_default=func.now(), nullable=False)
    updatedAt = Column("updated_at", DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

    # Relationships
    farmer_profile = relationship("FarmerProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    customer_profile = relationship("CustomerProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    products = relationship("Product", back_populates="farmer", cascade="all, delete-orphan")
    cart_items = relationship("CartItem", back_populates="user", cascade="all, delete-orphan")
    orders = relationship("Order", back_populates="customer", foreign_keys="Order.customerId", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")


class RevokedToken(Base):
    __tablename__ = "revoked_tokens"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    jti = Column(String(64), unique=True, index=True, nullable=False)
    expires_at = Column(DateTime, nullable=True)
    revoked_at = Column(DateTime, server_default=func.now(), nullable=False)
