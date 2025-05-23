import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
import uuid

@pytest.mark.asyncio
async def test_complete_route_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear una ruta
        payload = {
            "origin": "Warehouse A",
            "destination": "Customer B",
            "estimated_time": 30,
            "distance_km": 7.2,
            "driver_id": None, # Or a valid driver_id if needed for completion logic later
            "order_ids": [] # Or valid order_ids if needed
        }
        create_response = await client.post("/routes/", json=payload)
        assert create_response.status_code == 200 # Ensure route creation is successful
        route_id = create_response.json()["id"]

        # Marcar como completada
        response = await client.patch(f"/routes/{route_id}/complete")
        assert response.status_code == 200
        assert response.json()["message"] == f"Route {route_id} completed successfully"
