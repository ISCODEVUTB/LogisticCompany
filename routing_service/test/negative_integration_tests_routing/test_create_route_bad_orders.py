import pytest
from httpx import ASGITransport, AsyncClient

from routing_service.app.main import app


@pytest.mark.asyncio
async def test_create_route_with_invalid_orders():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        payload = {
            "origin": "Bodega B",
            "destination": "Cliente Y",
            "estimated_time": 45,  # Example value
            "distance_km": 5.0,  # Example value
            "driver_id": None,
            "order_ids": ["invalid-order-123", "nonexistent-order-456"],
        }

        response = await client.post("/api/routes/", json=payload)

        assert response.status_code == 400
        assert response.json()["detail"] == "One or more orders not found"
