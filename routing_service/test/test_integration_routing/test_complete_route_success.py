import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
import uuid

@pytest.mark.asyncio
async def test_complete_route_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear una ruta sin órdenes ni conductor
        route_id = str(uuid.uuid4())
        payload = {
            "id": route_id,
            "driver_id": None,
            "order_ids": []
        }
        await client.post("/routes/", json=payload)

        # Marcar como completada
        response = await client.patch(f"/routes/{route_id}/complete")
        assert response.status_code == 200
        assert response.json()["message"] == f"Route {route_id} completed successfully"
