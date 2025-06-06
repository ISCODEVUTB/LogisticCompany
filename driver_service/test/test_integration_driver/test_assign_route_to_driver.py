import pytest
from httpx import AsyncClient
from httpx._transports.asgi import ASGITransport
from driver_service.app.main import app

@pytest.mark.asyncio
async def test_assign_route_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear conductor
        payload = {
            "name": "Laura Rodríguez",
            "license_id": "ROUTE001",
            "phone": "3101234567",
            "email": "laura@example.com"
        }
        response_create = await client.post("/api/drivers/", json=payload)
        driver_id = response_create.json().get('driver_id')

        # Asignar ruta
        response_assign = await client.patch(f"/api/drivers/{driver_id}/assign-route?route_id=R123")
        assert response_assign.status_code == 200
        assert response_assign.json()["message"] == f"Route R123 assigned to driver {driver_id}"
