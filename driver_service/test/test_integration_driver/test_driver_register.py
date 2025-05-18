import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_register_driver_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        payload = {
            "name": "Carlos Sánchez",
            "license_number": "ABC123456",
            "phone": "3101234567",
            "email": "carlos@example.com"
        }
        response = await client.post("/drivers", json=payload)
        assert response.status_code == 201
        data = response.json()
        assert "id" in data
        assert data["name"] == payload["name"]
        assert data["license_number"] == payload["license_number"]
