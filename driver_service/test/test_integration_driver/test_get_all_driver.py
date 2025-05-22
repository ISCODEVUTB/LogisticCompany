import pytest
from httpx import AsyncClient
from httpx._transports.asgi import ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_get_all_drivers_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Registramos al menos un conductor para asegurar que la lista no esté vacía
        payload = {
            "name": "Carlos Mendoza",
            "license_id": "CAR123456", # Changed from license_number
            "phone": "3011112233"
            # "email" field removed
        }
        create_response = await client.post("/drivers/", json=payload)
        assert create_response.status_code == 201 # Ensure successful creation

        # Obtenemos la lista de conductores
        response = await client.get("/drivers/")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        # Ensure the list is not empty before trying to access driver details
        assert len(data) > 0 
        assert any(driver["license_id"] == "CAR123456" for driver in data)
