from app.models.tracking import TrackingEvent
from app.schemas.tracking_schemas import TrackingEventCreate, TrackingHistoryOut, TrackingEventOut
from app.repository.tracking_repo import save_tracking_event, get_tracking_events_by_code, get_all_tracking_events

class TrackingService:
    def add_tracking_event(self, data: TrackingEventCreate):
        event = TrackingEvent(
            tracking_code=data.tracking_code,
            status=data.status,
            timestamp=data.timestamp
        )
        save_tracking_event(event)
        return {"message": "Tracking event recorded"}

    def get_history(self, tracking_code: str) -> TrackingHistoryOut:
        events = get_tracking_events_by_code(tracking_code)
        history = [TrackingEventOut(**e.__dict__) for e in events]
        return TrackingHistoryOut(tracking_code=tracking_code, history=history)

    def get_all_events(self):
        events = get_all_tracking_events()
        return [e.__dict__ for e in events]
