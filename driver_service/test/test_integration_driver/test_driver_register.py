import pytest
from httpx import AsyncClient, ASGITransport
from driver_service.app.main import app # This should resolve to driver_service.app.main

@pytest.mark.asyncio
async def test_register_driver_success(): # Assuming original name was kept
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        payload = {
            "name": "Test Driver Minimal",
            "license_id": "TDMIN123",
            "phone": "1234567890"
        }
        response = await client.post("/api/drivers/", json=payload)
        assert response.status_code == 201
        response_data = response.json()
        assert response_data["name"] == payload["name"]
        assert response_data["license_id"] == payload["license_id"]
        assert response_data["phone"] == payload["phone"]
        assert "driver_id" in response_data
        assert response_data["status"] == "available"
