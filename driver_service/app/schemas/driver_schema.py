from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class DriverCreateDTO(BaseModel):
    name: str
    license_id: str
    phone: str


class DriverUpdateDTO(BaseModel):
    name: Optional[str] = None
    license_id: Optional[str] = None
    phone: Optional[str] = None
    status: Optional[str] = None


class DriverResponseDTO(BaseModel):
    driver_id: str
    name: str
    license_id: str
    phone: str
    status: str
    created_at: datetime
    updated_at: datetime
