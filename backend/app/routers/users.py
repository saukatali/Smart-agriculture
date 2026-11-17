from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.user import User
from app.schemas.user import UserResponse, UserUpdate
from app.dependencies.authentication import get_current_user

router = APIRouter(prefix="/api/users", tags=["Users"])

@router.get("/profile", summary="Get user profile", response_model=UserResponse)
def get_profile(current_user: User = Depends(get_current_user)):
    return current_user

@router.put("/profile", summary="Update user profile")
def update_profile(
    data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    for key, val in data.model_dump(exclude_unset=True).items():
        setattr(current_user, key, val)
    db.commit()
    db.refresh(current_user)
    return {"success": True, "message": "Profile updated", "user": current_user}

