import pytest
from httpx import AsyncClient, ASGITransport
from driver_service.app.main import app

@pytest.mark.asyncio
async def test_create_driver_missing_fields():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Falta el campo "license_number"
        payload = {
            "name": "Faltan Datos",
            "phone": "3000000000",
            "email": "falta@example.com"
        }

        response = await client.post("/drivers/", json=payload)
        assert response.status_code == 404
        print(response.text)

