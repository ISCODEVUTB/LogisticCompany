import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
async def test_create_route_bad_driver():
    async with AsyncClient(app=app, base_url="https://test") as ac:
        payload = {
            "driver_id": "non-existent-driver",
            "order_ids": ["order1", "order2"]
        }
        response = await ac.post("/routes/", json=payload)

    assert response.status_code == 400
    assert response.json() == {"detail": "Not Found"}
