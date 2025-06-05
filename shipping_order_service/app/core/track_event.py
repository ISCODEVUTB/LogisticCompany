from datetime import datetime, timezone

import httpx

TRACKING_URL = "http://localhost:8003/tracking/track"  # Puerto de tracking_service


async def send_tracking_event(tracking_code: str, status: str):
    payload = {
        "tracking_code": tracking_code,
        "status": status,
        "timestamp": datetime.fromtimestamp(
            datetime.now().timestamp(), timezone.utc
        ).isoformat(),
    }
    try:
        async with httpx.AsyncClient() as client:
            await client.post(TRACKING_URL, json=payload)
    except Exception as e:
        print(f"Error sending tracking event: {e}")
