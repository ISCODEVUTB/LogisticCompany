import pytest
from httpx import AsyncClient, Response
from app.main import app
from httpx._transports.asgi import ASGITransport

@pytest.mark.asyncio
async def test_update_shipping_order_status(mocker):
    # Define the dictionary for the tracking service POST response
    # This mock is used for the initial order creation.
    mock_tracking_dict_response = {
        'order_id': 'mocked-order-123', # Essential for response.json()["order_id"]
        'tracking_code': 'mocked-tracking-code-update', # Added for consistency
        'status': 'created', # Added for consistency
        'mock_tracking_status': 'event_sent' # Original field from the file
    }

    # Mock the tracking service client for POST
    # This will be returned for the order creation call.
    # If the app's status update logic also calls this, it will also receive this response.
    mocker.patch(
        'app.services.tracking_service_client.httpx.AsyncClient.post',
        new_callable=mocker.AsyncMock, # Ensures the mock behaves as an async function
        return_value=Response(201, json=mock_tracking_dict_response)
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
