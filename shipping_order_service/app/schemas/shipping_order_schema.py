from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class SenderReceiver(BaseModel):
    name: str
    address: str
    phone: str


class PackageInfo(BaseModel):
    weight: float  # en kg
    dimensions: str  # formato: "LxWxH", por ejemplo "30x20x10"


class ShippingOrderCreateDTO(BaseModel):
    sender: SenderReceiver
    receiver: SenderReceiver
    pickup_date: datetime
    package: PackageInfo


class ShippingOrderResponseDTO(BaseModel):
    order_id: str
    tracking_code: str
    status: str
    created_at: datetime
