from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel


class Route(BaseModel):
    id: str
    origin: str
    destination: str
    estimated_time: int
    distance_km: float
    driver_id: Optional[str] = None
    order_ids: List[str] = []
    created_at: datetime
