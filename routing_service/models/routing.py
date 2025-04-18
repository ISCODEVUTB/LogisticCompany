from pydantic import BaseModel
from datetime import datetime

class Route(BaseModel):
    id: int
    origin: str
    destination: str
    estimated_time: int  # in minutes
    distance_km: float
    created_at: datetime
