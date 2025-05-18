import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_update_driver_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear conductor primero
        payload = {
            "name": "Laura Gómez",
            "license_number": "LAU456789",
            "phone": "3055556677",
            "email": "laura@example.com"
        }
        response_create = await client.post("/drivers", json=payload)
        driver_id = response_create.json()["driver_id"]

        # Actualizar conductor
        update_payload = {
            "phone": "3200001111",
            "email": "laura.nueva@example.com"
        }
        response_update = await client.patch(f"/drivers/{driver_id}", json=update_payload)
        assert response_update.status_code == 200
        assert response_update.json()["message"] == "Driver updated successfully"
