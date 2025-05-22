import pytest
from httpx import AsyncClient, Response
from app.main import app
from httpx._transports.asgi import ASGITransport

@pytest.mark.asyncio
async def test_update_shipping_order_status(mocker):
    # Mock the tracking service client for POST (used for both order creation and status update)
    # A generic response should be fine as the test mainly checks the status code of the shipping service
    mock_tracking_dict_response = {'mock_tracking_status': 'event_sent'}
    mocker.patch(
        'app.services.tracking_service_client.httpx.AsyncClient.post', # Corrected path
        new_callable=mocker.AsyncMock,
        return_value=mock_tracking_dict_response # Changed to a dict
    )

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear orden
        payload = {
            "sender": {"name": "Carlos Méndez", "address": "Diagonal 99", "phone": "3023334444"},
            "receiver": {"name": "Lucía Martínez", "address": "Transversal 85", "phone": "3009988777"},
            "pickup_date": "2025-05-05T09:30:00",
            "package": {"weight": 3.1, "dimensions": "25x25x25"}
        }
        response = await client.post("/orders", json=payload)
        order_id = response.json()["order_id"]

        # Cambiar estado
        status_response = await client.post(f"/orders/{order_id}/status", params={"status": "shipped"})
        assert status_response.status_code == 204
