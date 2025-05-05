import pytest
from httpx import AsyncClient
from unittest.mock import patch
from app.main import app
from app.services.routing_service import RouteService

@pytest.mark.asyncio
async def test_complete_route_update_fail():
    # Crear ruta con órdenes
    service = RouteService()
    route = service.create({
        "driver_id": "driver-x",
        "order_ids": ["order-3"]
    })

    # Simular fallos en update_order_statuses y mark_as_completed
    with patch("app.api.routes.update_order_statuses", return_value=True), \
         patch.object(service, "mark_as_completed", return_value=False):
        async with AsyncClient(app=app, base_url="https://test") as ac:
            response = await ac.patch(f"/routes/{route['id']}/complete")

    assert response.status_code == 500
    assert response.json()["detail"] == "Failed to update route"
