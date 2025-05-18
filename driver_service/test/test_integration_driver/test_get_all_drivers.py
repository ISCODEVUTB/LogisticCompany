import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_get_all_drivers_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Registramos al menos un conductor para asegurar que la lista no esté vacía
        payload = {
            "name": "Carlos Mendoza",
            "license_number": "CAR123456",
            "phone": "3011112233",
            "email": "carlos@example.com"
        }
        await client.post("/drivers", json=payload)

        # Obtenemos la lista de conductores
        response = await client.get("/drivers/")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert any(driver["license_number"] == "CAR123456" for driver in data)
