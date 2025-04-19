class RouteCreate(BaseModel):
    origin: str
    destination: str
    estimated_time: int
    distance_km: float

class RouteOut(RouteCreate):
    id: int
