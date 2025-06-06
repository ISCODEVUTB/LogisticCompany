import pytest
from httpx import AsyncClient
from httpx._transports.asgi import ASGITransport
from driver_service.app.main import app

@pytest.mark.asyncio
async def test_create_driver_missing_fields():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Falta el campo "license_id"
        payload = {
            "name": "Faltan Datos",
            "phone": "3000000000"
            # "license_id" is intentionally missing
        }

        response = await client.post("/drivers/", json=payload)
        assert response.status_code == 422
        # Optional: further assert the detail of the 422 error if known
        # For example: assert "license_id" in response.json()["detail"][0]["loc"]
        print(response.text)
