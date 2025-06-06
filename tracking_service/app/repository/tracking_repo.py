import json
import os
from typing import List
from app.models.tracking import TrackingEvent
from datetime import datetime

DATA_FILE = "app/repository/tracking.json"


def _load_data() -> List[dict]:
    if not os.path.exists(DATA_FILE):
        return []
    with open(DATA_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def _save_data(data: List[dict]):
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4, default=str)  # default=str para datetime


def save_tracking_event(event: TrackingEvent):
    data = _load_data()
    data.append({
        "tracking_code": event.tracking_code,
        "status": event.status,
        "timestamp": event.timestamp.isoformat()
    })
    _save_data(data)


def get_tracking_events_by_code(tracking_code: str) -> List[TrackingEvent]:
    data = _load_data()
    return [
        TrackingEvent(
            tracking_code=entry["tracking_code"],
            status=entry["status"],
            timestamp=datetime.fromisoformat(entry["timestamp"])
        )
        for entry in data
        if entry["tracking_code"] == tracking_code
    ]
