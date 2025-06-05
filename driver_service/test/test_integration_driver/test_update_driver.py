import pytest
from httpx import AsyncClient
from httpx._transports.asgi import ASGITransport

from driver_service.app.main import app


@pytest.mark.asyncio
async def test_update_driver_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear conductor primero
        payload = {
            "name": "Laura Gómez",
            "license_id": "LAU456789",  # Changed from license_number
            "phone": "3055556677",
            # "email" field removed
        }
        response_create = await client.post("/api/drivers/", json=payload)
        assert response_create.status_code == 201  # Ensure successful creation
        # Assuming 'id' is the key
        driver_id = response_create.json()["driver_id"]

        # Actualizar conductor
        update_payload = {
            "phone": "3200001111"
            # "email" field removed from update payload as well
        }
        response_update = await client.patch(
            f"/api/drivers/{driver_id}", json=update_payload
        )
        assert response_update.status_code == 200
        assert response_update.json()["message"] == "Driver updated successfully"
