import pytest
from httpx import AsyncClient
from httpx._transports.asgi import ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_deactivate_driver_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear conductor primero
        payload = {
            "name": "Carlos Méndez",
            "license_number": "CAR567890",
            "phone": "3129988776",
            "email": "carlos@example.com"
        }
        response_create = await client.post("/drivers/", json=payload)
        driver_id = response_create.json()["driver_id"]

        # Desactivar conductor
        response_delete = await client.delete(f"/drivers/{driver_id}")
        assert response_delete.status_code == 200
        assert response_delete.json()["message"] == "Driver deactivated"
