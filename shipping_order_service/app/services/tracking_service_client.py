import httpx
from datetime import datetime
import os

TRACKING_SERVICE_URL = os.getenv("TRACKING_SERVICE_URL", "http://localhost:8003/tracking/track")

async def send_tracking_event(tracking_code: str, status: str, timestamp: datetime):
    url = TRACKING_SERVICE_URL
    payload = {
        "tracking_code": tracking_code,
        "status": status,
        "timestamp": timestamp.isoformat()
    }

    async with httpx.AsyncClient() as client:
        await client.post(url, json=payload)
