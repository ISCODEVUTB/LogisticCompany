import pytest
from httpx import AsyncClient, Response
from app.main import app
from httpx._transports.asgi import ASGITransport

@pytest.mark.asyncio
async def test_cancel_shipping_order(mocker):
    # Mock the tracking service client for order creation
    mock_tracking_response = Response(201, json={
        'order_id': 'mocked-order-123',
        'tracking_code': 'mocked-tracking-123',
        'status': 'created',
        'mock_tracking_status': 'event_sent'
    })
    
    # Mock for cancel operation - needs to return 204 status code
    mock_cancel_response = Response(204, json={})
    
    # Use side_effect to return different responses based on the call
    async def mock_post_side_effect(*args, **kwargs):
        # Check if this is a cancel operation based on URL
        if '/cancel' in str(args) or '/cancel' in str(kwargs):
            return mock_cancel_response
        return mock_tracking_response
    
    mock_post = mocker.patch(
        'app.services.tracking_service_client.httpx.AsyncClient.post',
        new_callable=mocker.AsyncMock,
        side_effect=mock_post_side_effect
    )

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
