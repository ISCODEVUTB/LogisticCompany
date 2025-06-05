from unittest.mock import patch

import pytest
from httpx import ASGITransport, AsyncClient

from routing_service.app.main import app
from routing_service.app.services.routing_service import RouteService


@pytest.mark.asyncio
async def test_complete_route_notify_driver_fail():
    # Crear una ruta de prueba con conductor asignado
    service = RouteService()
    route = service.create(
        {
            "origin": "Test Origin",
            "destination": "Test Destination",
            "estimated_time": 30,
            "distance_km": 5.0,
            "driver_id": "driver-test",
            "order_ids": [],
        }
    )

    with patch(
        "routing_service.app.api.routes.update_order_statuses", return_value=True
    ), patch(
        "routing_service.app.api.routes.notify_driver_assignment", return_value=False
    ):
        async with AsyncClient(
            transport=ASGITransport(app=app), base_url="https://test"
        ) as ac:
            response = await ac.patch(f"/api/routes/{route['id']}/complete")

    assert response.status_code == 500
    assert response.json()["detail"] == "Failed to update route"
