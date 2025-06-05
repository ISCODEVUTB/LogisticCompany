import pytest
from httpx import AsyncClient, Response
from httpx._transports.asgi import ASGITransport

from shipping_order_service.app.main import app


@pytest.mark.asyncio
async def test_cancel_shipping_order(mocker):
    # Define the dictionary for the tracking service response
    mock_tracking_dict_response = {
        "order_id": "mocked-order-123",
        "tracking_code": "mocked-tracking-123",
        "status": "created",
        "mock_tracking_status": "event_sent",
    }

    # Mock para la creación de órdenes (POST inicial)
    mock_create_response = Response(201, json=mock_tracking_dict_response)

    # Mock para la cancelación (POST a /cancel)
    mock_cancel_response = Response(204)

    # Usar side_effect para diferenciar entre creación y cancelación
    async def mock_post_side_effect(*args, **kwargs):
        # Si la URL contiene 'cancel', devolver respuesta de cancelación
        if "/cancel" in str(args) or "/cancel" in str(kwargs):
            return mock_cancel_response
        # De lo contrario, devolver respuesta de creación
        return mock_create_response

    # Configurar el mock con side_effect para manejar diferentes casos
    mocker.patch(
        "shipping_order_service.app.services.tracking_service_client.httpx.AsyncClient.post",
        new_callable=mocker.AsyncMock,
        side_effect=mock_post_side_effect,
    )

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Crear orden
        payload = {
            "sender": {
                "name": "Luis Díaz",
                "address": "Calle Falsa 123",
                "phone": "3001112233",
            },
            "receiver": {
                "name": "Ana Ruiz",
                "address": "Av Central 456",
                "phone": "3114445566",
            },
            "pickup_date": "2025-05-04T15:00:00",
            "package": {"weight": 1.2, "dimensions": "15x10x5"},
        }
        response = await client.post("/api/orders", json=payload)
        order_id = response.json()["order_id"]

        # Cancelar
        cancel_response = await client.post(f"/api/orders/{order_id}/cancel")
        assert cancel_response.status_code == 204
