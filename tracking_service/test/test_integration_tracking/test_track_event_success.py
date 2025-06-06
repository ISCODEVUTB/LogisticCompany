import pytest
import respx
import httpx
from httpx import Response

@pytest.mark.asyncio
async def test_track_event_success( ):
    with respx.mock() as mock:
        # Mock para el POST
        mock.post("https://test/tracking/track" ).mock(
            return_value=Response(
                status_code=200,
                json={
                    "tracking_code": "TRK123456",
                    "location": "Bogotá",
                    "status": "En tránsito",
                    "timestamp": "2024-05-01T10:00:00"
                }
            )
        )
        
        async with httpx.AsyncClient(base_url="https://test" ) as client:
            response = await client.post("/tracking/track", json={
                "tracking_code": "TRK123456",
                "location": "Bogotá",
                "status": "En tránsito",
                "timestamp": "2024-05-01T10:00:00"
            })
            
        assert response.status_code == 200
        data = response.json()
        assert data["tracking_code"] == "TRK123456"
        assert data["status"] == "En tránsito"
