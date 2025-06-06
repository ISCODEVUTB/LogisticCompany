import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_create_route_bad_driver():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="https://test") as ac:
        payload = {
            "origin": "Test Origin",
            "destination": "Test Destination",
            "estimated_time": 60, # Example value
            "distance_km": 10.5,  # Example value
            "driver_id": "non-existent-driver",
            "order_ids": ["order1", "order2"]
        }
        response = await ac.post("/routes/", json=payload)

    assert response.status_code == 400
    assert response.json()["detail"] == "Driver not found"
