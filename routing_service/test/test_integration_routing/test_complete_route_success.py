from unittest.mock import patch

import pytest
from httpx import ASGITransport, AsyncClient

from routing_service.app.main import app
from routing_service.app.services.routing_service import RouteService


@pytest.mark.asyncio
async def test_complete_route_success(): # Renamed test
    # Crear ruta con órdenes
    service = RouteService()
    route = service.create(
        {
            "origin": "Test Origin",
            "destination": "Test Destination",
            "estimated_time": 30,
            "distance_km": 5.0,
            "driver_id": "driver-x",
            "order_ids": ["order-3"],
        }
    )

    # Simular success in all dependent async calls
    with patch(
        "routing_service.app.api.routes.update_order_statuses", return_value=True
    ), patch(
        "routing_service.app.services.routing_service.RouteService.mark_as_completed",
        return_value=True,
    ), patch(
        "routing_service.app.api.routes.notify_driver_assignment", return_value=True # Added patch
    ):
        async with AsyncClient(
            transport=ASGITransport(app=app), base_url="https://test"
        ) as ac:
            response = await ac.patch(f"/api/routes/{route['id']}/complete")

    assert response.status_code == 200
    assert response.json()["message"] == f"Route {route['id']} completed successfully"
