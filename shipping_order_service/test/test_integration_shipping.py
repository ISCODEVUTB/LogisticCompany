import pytest
from httpx import AsyncClient
from app.main import app 

@pytest.mark.asyncio
async def test_create_shipping_order_integration():
    async with AsyncClient(app=app, base_url="http://test") as client:
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

        response = await client.post("/shipping-orders", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "order_id" in data
        assert "tracking_code" in data
        assert data["status"] == "created"
