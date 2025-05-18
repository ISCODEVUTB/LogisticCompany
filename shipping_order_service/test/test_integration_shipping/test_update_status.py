import pytest
from httpx import AsyncClient
from app.main import app
from httpx._transports.asgi import ASGITransport

@pytest.mark.asyncio
async def test_update_shipping_order_status():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear orden
        payload = {
            "sender": {"name": "Carlos Méndez", "address": "Diagonal 99", "phone": "3023334444"},
            "receiver": {"name": "Lucía Martínez", "address": "Transversal 85", "phone": "3009988777"},
            "pickup_date": "2025-05-05T09:30:00",
            "package": {"weight": 3.1, "dimensions": "25x25x25"}
        }
        response = await client.post("/orders", json=payload)
        order_id = response.json()["order_id"]

        # Cambiar estado
        status_response = await client.post(f"/orders/{order_id}/status", params={"status": "shipped"})
        assert status_response.status_code == 204
