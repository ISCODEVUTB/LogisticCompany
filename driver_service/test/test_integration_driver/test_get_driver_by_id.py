import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_get_driver_by_id_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Primero registramos un conductor
        payload = {
            "name": "Laura Gómez",
            "license_number": "XYZ987654",
            "phone": "3007654321",
            "email": "laura@example.com"
        }
        create_response = await client.post("/drivers", json=payload)
        assert create_response.status_code == 201
        driver_id = create_response.json()["id"]

        # Ahora intentamos obtenerlo por su ID
        get_response = await client.get(f"/drivers/{driver_id}")
        assert get_response.status_code == 200
        data = get_response.json()
        assert data["id"] == driver_id
        assert data["name"] == payload["name"]
