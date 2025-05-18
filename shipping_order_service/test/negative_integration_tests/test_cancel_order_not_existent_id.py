import pytest
from httpx import AsyncClient
from app.main import app
from httpx._transports.asgi import ASGITransport
@pytest.mark.asyncio
async def test_cancel_order_not_found():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        response = await client.post("/orders/nonexistent-id/cancel")
        assert response.status_code == 400
        assert response.json()["detail"] == "Unable to cancel the order"
