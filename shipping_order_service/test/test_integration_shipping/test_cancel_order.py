import pytest
from httpx import AsyncClient, Response
from app.main import app
from httpx._transports.asgi import ASGITransport

@pytest.mark.asyncio
async def test_cancel_shipping_order(mocker):
    # Define the dictionary for the tracking service response
    mock_tracking_dict_response = {
        'order_id': 'mocked-order-123',
        'tracking_code': 'mocked-tracking-123',
        'status': 'created',
        'mock_tracking_status': 'event_sent'
    }

    # Mock the tracking service client to return an httpx.Response
    # This mock will now be used for ALL calls to tracking_service_client.post
    mocker.patch(
        'app.services.tracking_service_client.httpx.AsyncClient.post',
        return_value=Response(201, json=mock_tracking_dict_response)
    )

    # NOTE: The original side_effect logic that differentiated between
    # order creation and cancellation for the tracking service is removed by this change.
    # If the test requires different responses for different calls to the tracking service,
    # this simplification might cause issues with the test's later stages (e.g., cancellation).

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear orden
        payload = {
            "sender": {"name": "Luis Díaz", "address": "Calle Falsa 123", "phone": "3001112233"},
            "receiver": {"name": "Ana Ruiz", "address": "Av Central 456", "phone": "3114445566"},
            "pickup_date": "2025-05-04T15:00:00",
            "package": {"weight": 1.2, "dimensions": "15x10x5"}
        }
        response = await client.post("/orders", json=payload)
        order_id = response.json()["order_id"]

        # Cancelar
        cancel_response = await client.post(f"/orders/{order_id}/cancel")
        assert cancel_response.status_code == 204
