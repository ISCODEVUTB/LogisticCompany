import pytest
from httpx import AsyncClient
from httpx._transports.asgi import ASGITransport
from driver_service.app.main import app

@pytest.mark.asyncio
async def test_deactivate_driver_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear conductor primero
        payload = {
            "name": "Carlos Méndez",
            "license_id": "CAR567890", # Changed from license_number
            "phone": "3129988776"
            # "email" field removed
        }
        response_create = await client.post("/drivers/", json=payload)
        assert response_create.status_code == 201 # Ensure we check for successful creation
        driver_id = response_create.json()["driver_id"] # Assuming 'id' is the key for the driver's ID

        # Desactivar conductor
        response_delete = await client.delete(f"/drivers/{driver_id}")
        assert response_delete.status_code == 200
        assert response_delete.json()["message"] == "Driver deactivated"
