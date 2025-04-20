from pydantic import BaseModel
from typing import Optional, List

class RouteCreate(BaseModel):
    origin: str
    destination: str
    estimated_time: int
    distance_km: float
    driver_id: Optional[str] = None
    order_ids: List[str] = []

class RouteOut(RouteCreate):
    id: str
