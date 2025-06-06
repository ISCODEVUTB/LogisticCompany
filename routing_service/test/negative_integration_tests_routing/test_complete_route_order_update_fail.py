import pytest
from httpx import AsyncClient, ASGITransport
from unittest.mock import patch
from app.main import app
from app.services.routing_service import RouteService

@pytest.mark.asyncio
async def test_complete_route_order_update_fail():
    # Crear ruta con órdenes asignadas
    service = RouteService()
    route = service.create({
        "origin": "Test Origin",
        "destination": "Test Destination",
        "estimated_time": 30,
        "distance_km": 5.0,
        "driver_id": "driver-test",
        "order_ids": ["order-1", "order-2"]
    })

    with patch("app.api.routes.update_order_statuses", return_value=False):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="https://test") as ac:
            response = await ac.patch(f"/routes/{route['id']}/complete")

    assert response.status_code == 500
    assert response.json()["detail"] == "Failed to update order statuses"
