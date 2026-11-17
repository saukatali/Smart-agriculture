from typing import Optional
from fastapi import APIRouter, Depends, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.services.auth_service import AuthService, _serialize_user
from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse
from app.dependencies.authentication import get_current_user, oauth2_scheme
from app.models.user import User

router = APIRouter(prefix="/api/auth", tags=["Authentication"])


@router.post("/register", summary="Register a new user account", status_code=status.HTTP_201_CREATED)
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    """
    Register a new user in MySQL with bcrypt password hashing and automatic role profile creation.
    """
    return AuthService.register_user(db, data)


@router.post("/login", summary="User login with email/phone and password", response_model=TokenResponse)
def login(data: LoginRequest, db: Session = Depends(get_db)):
    """
    Authenticate user and issue a signed JWT access token.
    """
    return AuthService.authenticate_user(db, data.email, data.password)


@router.post("/token", summary="OAuth2 compatible token login for Swagger UI Authorize button", response_model=TokenResponse)
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """
    OAuth2 Password Bearer login endpoint powering Swagger UI Authorize dialog.
    """
    return AuthService.authenticate_user(db, form_data.username, form_data.password)


@router.get("/me", summary="Get authenticated user profile")
def get_me(current_user: User = Depends(get_current_user)):
    """
    Return currently signed-in user details.
    """
    return {
        "success": True,
        "user": _serialize_user(current_user),
        **_serialize_user(current_user),
    }


@router.post("/logout", summary="Logout current user session")
def logout(
    token: Optional[str] = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
):
    """
    Invalidate current user session by revoking the JWT token.
    """
    AuthService.revoke_token(db, token)
    return {"success": True, "message": "Logged out successfully."}
