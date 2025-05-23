import pytest
from httpx import AsyncClient, Response
from shipping_order_service.app.main import app
from httpx._transports.asgi import ASGITransport

@pytest.mark.asyncio
async def test_track_shipping_order_by_code(mocker):
    # Define dictionary for the POST request mock (order creation)
    mock_tracking_dict_response = {
        'order_id': 'mocked-order-123',
        'tracking_code': 'mocked_tracking_code_from_post', # This will be asserted
        'status': 'created',
        'mock_tracking_status': 'event_sent'
    }
    # Mock the tracking service client for POST
    mocker.patch(
        'app.services.tracking_service_client.httpx.AsyncClient.post',
        new_callable=mocker.AsyncMock,
        return_value=Response(201, json=mock_tracking_dict_response)
    )

    # Define dictionary for the GET request mock (order tracking)
    mock_get_tracking_response_dict = {
        'tracking_code': 'mocked_tracking_code_from_post', # Should match the one from POST
        'status': 'in_transit',
        'history': []
    }
    # Mock the tracking service client for GET
    mocker.patch(
        'app.services.tracking_service_client.httpx.AsyncClient.get',
        new_callable=mocker.AsyncMock,
        return_value=Response(200, json=mock_get_tracking_response_dict)
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
