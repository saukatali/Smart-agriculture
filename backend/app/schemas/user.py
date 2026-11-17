from typing import Optional
from datetime import datetime
from pydantic import BaseModel, EmailStr, computed_field


class UserBase(BaseModel):
    name: str
    email: EmailStr
    role: str
    phone: Optional[str] = None
    location: Optional[str] = None
    avatar: Optional[str] = None
    status: str = "active"


class UserResponse(UserBase):
    id: int
    createdAt: Optional[datetime] = None
    updatedAt: Optional[datetime] = None

    @computed_field
    @property
    def full_name(self) -> str:
        return self.name

    @computed_field
    @property
    def created_at(self) -> Optional[datetime]:
        return self.createdAt

    @computed_field
    @property
    def updated_at(self) -> Optional[datetime]:
        return self.updatedAt

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    location: Optional[str] = None
    avatar: Optional[str] = None
