import httpx
from datetime import datetime

async def send_tracking_event(tracking_code: str, status: str, timestamp: datetime):
    url = "http://localhost:8003/tracking/track"
    payload = {
        "tracking_code": tracking_code,
        "status": status,
        "timestamp": timestamp.isoformat()
    }

    async with httpx.AsyncClient() as client:
        await client.post(url, json=payload)
