import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_create_route_with_invalid_orders():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        payload = {
            "driver_id": None,
            "order_ids": ["invalid-order-123", "nonexistent-order-456"],
            "origin": "Bodega B",
            "destination": "Cliente Y"
        }

        response = await client.post("/routes/", json=payload)

        assert response.status_code == 400
        assert response.json()["detail"] == "One or more orders not found"
