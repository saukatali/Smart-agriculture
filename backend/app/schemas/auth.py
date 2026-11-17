import re
from typing import Optional
from pydantic import AliasChoices, BaseModel, EmailStr, Field, field_validator, model_validator


class LoginRequest(BaseModel):
    email: str = Field(..., min_length=1, description="User email or mobile number")
    password: str = Field(..., min_length=1, description="User password")

    @field_validator("email")
    @classmethod
    def validate_email_non_empty(cls, v: str) -> str:
        cleaned = v.strip()
        if not cleaned:
            raise ValueError("Email address is required.")
        return cleaned


class RegisterRequest(BaseModel):
    name: str = Field(
        ...,
        min_length=2,
        max_length=255,
        validation_alias=AliasChoices("full_name", "name"),
    )
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)
    confirm_password: Optional[str] = Field(
        default=None,
        validation_alias=AliasChoices("confirm_password", "confirmPassword"),
    )
    role: str = Field("customer", pattern="^(farmer|customer|admin)$")
    phone: str = Field(..., min_length=7, max_length=20)
    location: Optional[str] = "Ahmedabad, Gujarat"
    farmName: Optional[str] = None
    farmLocation: Optional[str] = None

    @field_validator("name")
    @classmethod
    def validate_name(cls, v: str) -> str:
        cleaned = v.strip()
        if len(cleaned) < 2:
            raise ValueError("Full name must be at least 2 characters.")
        return cleaned

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        cleaned = v.strip()
        digits = re.sub(r"\D", "", cleaned)
        if len(digits) < 10 or len(digits) > 15:
            raise ValueError("Please enter a valid 10 to 15 digit phone number.")
        return cleaned

    @field_validator("password")
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters long.")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must include at least one uppercase letter.")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must include at least one lowercase letter.")
        if not re.search(r"\d", v):
            raise ValueError("Password must include at least one number.")
        return v

    @model_validator(mode="after")
    def check_passwords_match(self):
        if self.confirm_password is not None and self.confirm_password != self.password:
            raise ValueError("Passwords do not match.")
        return self


class TokenResponse(BaseModel):
    access_token: str
    token: Optional[str] = None
    token_type: str = "bearer"
    success: bool = True
    message: Optional[str] = "Success"
    user: dict

    class Config:
        extra = "allow"


class TokenData(BaseModel):
    id: Optional[int] = None
    email: Optional[str] = None
    role: Optional[str] = None
    name: Optional[str] = None
