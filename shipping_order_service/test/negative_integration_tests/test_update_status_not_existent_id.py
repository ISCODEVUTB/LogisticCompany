import pytest
from httpx import AsyncClient
from app.main import app
from httpx._transports.asgi import ASGITransport
@pytest.mark.asyncio
async def test_update_status_not_found():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        response = await client.post("/orders/nonexistent-id/status", params={"status": "shipped"})
        assert response.status_code == 404
        assert response.json()["detail"] == "Not Found"
