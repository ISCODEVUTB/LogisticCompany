import pytest
from httpx import AsyncClient, ASGITransport
from routing_service.app.main import app
import uuid

@pytest.mark.asyncio
async def test_delete_route_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Creamos una ruta de prueba
        payload = {
            "origin": "Source X",
            "destination": "Destination Y",
            "estimated_time": 75,
            "distance_km": 15.0,
            "driver_id": None,
            "order_ids": []
        }
        create_response = await client.post("/api/routes/", json=payload)
        assert create_response.status_code == 200 # Ensure route creation is successful
        route_id = create_response.json()["id"]

        # Luego la eliminamos
        response = await client.delete(f"/api/routes/{route_id}")
        assert response.status_code == 200
        assert response.json()["message"] == f"Route {route_id} deleted"
