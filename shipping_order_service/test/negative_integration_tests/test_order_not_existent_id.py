import pytest
from httpx import AsyncClient
from httpx._transports.asgi import ASGITransport

from shipping_order_service.app.main import app


@pytest.mark.asyncio
async def test_get_order_not_found():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        response = await client.get("/api/orders/nonexistent-id")
        assert response.status_code == 404
        assert response.json()["detail"] == "Order not found"
