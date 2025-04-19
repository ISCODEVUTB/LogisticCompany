from datetime import datetime


class TrackingEvent:
    def __init__(self, tracking_code: str, status: str, timestamp: datetime):
        self.tracking_code = tracking_code
        self.status = status
        self.timestamp = timestamp
