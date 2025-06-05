# test/test_shipping_order.py
from datetime import datetime
from unittest.mock import AsyncMock, patch

import pytest

from shipping_order_service.app.schemas.shipping_order_schema import \
    ShippingOrderCreateDTO
from shipping_order_service.app.services import shipping_order_service


@pytest.mark.asyncio
@patch(
    "shipping_order_service.app.services.shipping_order_service.send_tracking_event",
    new_callable=AsyncMock,
)
async def test_create_shipping_order_success(mock_send_tracking_event):
    dto = ShippingOrderCreateDTO(
        sender={"name": "Juan Pérez", "address": "Calle 123", "phone": "3123456789"},
        receiver={
            "name": "María Gómez",
            "address": "Avenida 456",
            "phone": "9876543210",
        },
        pickup_date=datetime.now(),
        package={"weight": 2.5, "dimensions": "30x10x20"},
    )

    result = await shipping_order_service.create_shipping_order(dto)

    assert result.order_id
    assert result.tracking_code
    assert result.status == "created"
    assert isinstance(result.created_at, datetime)

    # Verificamos que el mock fue llamado
    mock_send_tracking_event.assert_awaited_once()
