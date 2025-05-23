import pytest
from httpx import AsyncClient, Response
from shipping_order_service.app.main import app
from httpx._transports.asgi import ASGITransport

@pytest.mark.asyncio
async def test_create_shipping_order_integration(mocker):
    # Define the dictionary for the tracking service response
    mock_tracking_dict_response = {
        'order_id': 'mocked-order-123',
        'tracking_code': 'mocked-tracking-123',
        'status': 'created',
        'mock_tracking_status': 'event_sent'
    }

    # Mock the tracking service client to return an httpx.Response
    mocker.patch(
        'app.services.tracking_service_client.httpx.AsyncClient.post', # Corrected path
        new_callable=mocker.AsyncMock, # Ensures the mock behaves as an async function
        return_value=Response(201, json=mock_tracking_dict_response)
    )

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        payload = {
            "sender": {
                "name": "Juan Pérez",
                "address": "Calle 123",
                "phone": "3123456789"
            },
            "receiver": {
                "name": "María Gómez",
                "address": "Avenida 456",
                "phone": "9876543210"
            },
            "pickup_date": "2025-05-04T12:00:00",
            "package": {
                "weight": 2.5,
                "dimensions": "30x10x20"
            }
        }

        response = await client.post("/orders", json=payload)
        assert response.status_code == 201
        data = response.json()
        assert "order_id" in data
        assert "tracking_code" in data
        assert data["status"] == "created"
