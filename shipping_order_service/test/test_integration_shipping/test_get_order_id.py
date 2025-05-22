import pytest
from httpx import AsyncClient, Response
from httpx._transports.asgi import ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_get_shipping_order_by_id(mocker):
    # Mock the tracking service client for the order creation part
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
            "sender": {"name": "Juan Pérez", "address": "Calle 123", "phone": "3123456789"},
            "receiver": {"name": "María Gómez", "address": "Avenida 456", "phone": "9876543210"},
            "pickup_date": "2025-05-04T12:00:00",
            "package": {"weight": 2.5, "dimensions": "30x10x20"}
        }
        create_response = await client.post("/orders", json=payload)
        assert create_response.status_code == 201
        order_id = create_response.json()["order_id"]

        # Obtener orden
        get_response = await client.get(f"/orders/{order_id}")
        assert get_response.status_code == 200
        data = get_response.json()
        assert data["order_id"] == order_id
        assert data["sender"]["name"] == "Juan Pérez"
