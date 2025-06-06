from fastapi import APIRouter
from app.services.tracking_service import TrackingService
from app.schemas.tracking_schemas import TrackingEventCreate

router = APIRouter()
service = TrackingService()


@router.post("/track")
def track_package(data: TrackingEventCreate):
    return service.add_tracking_event(data)


@router.get("/track/{tracking_code}")
def get_tracking_history(tracking_code: str):
    return service.get_history(tracking_code)
