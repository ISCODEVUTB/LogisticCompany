import pytest
from httpx import AsyncClient, ASGITransport
from app.main import 

@pytest.mark.asyncio
async def test_create_shipping_order_integration():
   transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {
            "sender": {
                "name": "Juan Pérez",
                "address": "Calle 123",
                "phone": "3123456789"
            },
            "receiver": {
                "name": "María Gómez",
                "address": "Avenida 456",
                "phone": "9876543210"
            },
            "pickup_date": "2025-05-04T12:00:00",
            "package": {
                "weight": 2.5,
                "dimensions": "30x10x20"
            }
        }

        response = await client.post("/orders", json=payload)
        assert response.status_code == 201
        data = response.json()
        assert "order_id" in data
        assert "tracking_code" in data
        assert data["status"] == "created"
