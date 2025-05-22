import pytest
from httpx import AsyncClient, Response
from app.main import app
from httpx._transports.asgi import ASGITransport

@pytest.mark.asyncio
async def test_track_shipping_order_by_code(mocker):
    # Mock the tracking service client for POST (order creation)
    mock_tracking_response = Response(201, json={
        'order_id': 'mocked-order-123',
        'tracking_code': 'mocked_tracking_code_from_post',
        'status': 'created',
        'mock_tracking_status': 'event_sent'
    })
    mocker.patch(
        'app.services.tracking_service_client.httpx.AsyncClient.post', # Corrected path
        new_callable=mocker.AsyncMock,
        return_value=mock_tracking_response
    )

    # Mock the tracking service client for GET (order tracking)
    # The expected response structure for tracking might be different, e.g., a list of events or current status
    mock_get_response = Response(200, json={'tracking_code': 'mocked_tracking_code_from_post', 'status': 'in_transit', 'history': []})
    mocker.patch(
        'app.services.tracking_service_client.httpx.AsyncClient.get', # Corrected path
        new_callable=mocker.AsyncMock,
        return_value=mock_get_response
    )

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear orden
        payload = {
            "sender": {"name": "Laura Ríos", "address": "Carrera 45", "phone": "3105678901"},
            "receiver": {"name": "Pedro Quintero", "address": "Calle 77", "phone": "3211234567"},
            "pickup_date": "2025-05-05T18:00:00",
            "package": {"weight": 4.0, "dimensions": "40x40x40"}
        }
        response = await client.post("/orders", json=payload)
        # The tracking_code here will be from the POST mock
        tracking_code = response.json()["tracking_code"] 
        assert tracking_code == 'mocked_tracking_code_from_post'


        # Rastrear
        track_response = await client.get(f"/orders/track/{tracking_code}")
        assert track_response.status_code == 200
        data = track_response.json()
        # This data comes from the GET mock
        assert data["tracking_code"] == tracking_code 
        assert data["status"] == "in_transit"
