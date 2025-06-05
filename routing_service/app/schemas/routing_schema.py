from typing import List, Optional

from pydantic import BaseModel


class RouteCreate(BaseModel):
    origin: str
    destination: str
    estimated_time: int
    distance_km: float
    driver_id: Optional[str] = None
    order_ids: List[str] = []


class RouteOut(RouteCreate):
    id: str


class RouteDriverUpdate(BaseModel):
    driver_id: str
