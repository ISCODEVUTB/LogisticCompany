from pydantic import BaseModel
from datetime import datetime
from typing import List


class TrackingEventCreate(BaseModel):
    tracking_code: str
    status: str
    timestamp: datetime


class TrackingEventOut(BaseModel):
    tracking_code: str
    status: str
    timestamp: datetime


class TrackingHistoryOut(BaseModel):
    tracking_code: str
    history: List[TrackingEventOut]