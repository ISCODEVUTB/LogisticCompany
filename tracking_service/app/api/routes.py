from fastapi import APIRouter

from app.schemas.tracking_schemas import TrackingEventCreate
from app.services.tracking_service import TrackingService

router = APIRouter()
service = TrackingService()


@router.post("/track")
def track_package(data: TrackingEventCreate):
    return service.add_tracking_event(data)


@router.get("/track/{tracking_code}")
def get_tracking_history(tracking_code: str):
    return service.get_history(tracking_code)


@router.get("/", response_model=list)
def get_all_events():
    return service.get_all_events()


@router.get("", response_model=list)
def get_all_events_alias():
    return service.get_all_events()
