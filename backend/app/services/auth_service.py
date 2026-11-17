from datetime import datetime, timezone
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException, status

from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    decode_access_token,
)
from app.models.user import User, RevokedToken
from app.models.farmer import FarmerProfile
from app.models.customer import CustomerProfile
from app.schemas.auth import RegisterRequest


def _serialize_user(user: User) -> dict:
    return {
        "id": user.id,
        "full_name": user.name,
        "name": user.name,
        "email": user.email,
        "role": user.role,
        "phone": user.phone or user.mobile,
        "location": user.location,
        "avatar": user.avatar or user.profileImage,
        "status": user.status,
        "created_at": user.createdAt.isoformat() if user.createdAt else None,
        "updated_at": user.updatedAt.isoformat() if user.updatedAt else None,
    }


class AuthService:
    @staticmethod
    def authenticate_user(db: Session, identifier: str, password: str) -> dict:
        identifier = identifier.strip().lower()
        user = db.query(User).filter(
            (User.email == identifier) | (User.phone == identifier) | (User.mobile == identifier)
        ).first()

        if not user or not verify_password(password, user.password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
            )

        if user.status != "active":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Your account is inactive or suspended.",
            )

        token = create_access_token({
            "id": user.id,
            "email": user.email,
            "role": user.role,
            "name": user.name,
        })

        return {
            "success": True,
            "message": "Login successful!",
            "token": token,
            "access_token": token,
            "token_type": "bearer",
            "user": _serialize_user(user),
        }

    @staticmethod
    def register_user(db: Session, data: RegisterRequest) -> dict:
        normalized_email = data.email.lower().strip()
        existing = db.query(User).filter(User.email == normalized_email).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="An account with this email address already exists.",
            )

        hashed = get_password_hash(data.password)
        new_user = User(
            name=data.name.strip(),
            email=normalized_email,
            password=hashed,
            role=data.role,
            phone=data.phone.strip(),
            mobile=data.phone.strip(),
            location=data.location or "Ahmedabad, Gujarat",
            status="active",
            isVerified=True,
        )
        try:
            db.add(new_user)
            db.commit()
            db.refresh(new_user)
        except IntegrityError:
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="An account with this email address already exists.",
            )

        if data.role == "farmer":
            profile = FarmerProfile(
                userId=new_user.id,
                farmName=data.farmName or f"{new_user.name}'s Farm",
                farmLocation=data.farmLocation or new_user.location,
                availableProducts="Fresh Vegetables, Grains",
                farmingExperience=5,
                verificationStatus="verified",
                rating=5.0,
                reviewCount=0,
                totalSalesKg=0.0,
            )
            db.add(profile)
            db.commit()
        elif data.role == "customer":
            c_profile = CustomerProfile(
                userId=new_user.id,
                name=new_user.name,
                email=new_user.email,
                mobile=new_user.phone,
                address=new_user.location,
                deliveryAddress=new_user.location,
                orderCount=0,
                totalSpent=0.0,
            )
            db.add(c_profile)
            db.commit()

        token = create_access_token({
            "id": new_user.id,
            "email": new_user.email,
            "role": new_user.role,
            "name": new_user.name,
        })

        return {
            "success": True,
            "message": "Account registered successfully!",
            "token": token,
            "access_token": token,
            "token_type": "bearer",
            "user": _serialize_user(new_user),
        }

    @staticmethod
    def revoke_token(db: Session, token: Optional[str]) -> None:
        if not token:
            return
        payload = decode_access_token(token)
        if not payload or "jti" not in payload:
            return
        jti = str(payload["jti"])
        existing = db.query(RevokedToken).filter(RevokedToken.jti == jti).first()
        if existing:
            return
        exp_ts = payload.get("exp")
        expires_at = datetime.fromtimestamp(exp_ts, tz=timezone.utc).replace(tzinfo=None) if exp_ts else None
        db.add(RevokedToken(jti=jti, expires_at=expires_at))
        db.commit()
