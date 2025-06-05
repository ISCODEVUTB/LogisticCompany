import pytest
from httpx import AsyncClient
from httpx._transports.asgi import ASGITransport

from driver_service.app.main import app


@pytest.mark.asyncio
async def test_update_driver_with_invalid_id():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        driver_id = "nonexistent-id-999"
        update_payload = {"phone": "3110000000", "vehicle": "Van"}

        response = await client.patch(f"/api/drivers/{driver_id}", json=update_payload)
        assert response.status_code == 404
        assert response.json()["detail"] == "Driver not found"
