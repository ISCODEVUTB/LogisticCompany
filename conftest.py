import os
import sys
from unittest.mock import AsyncMock, patch

import pytest

# Este fixture se aplicará a todos los tests automáticamente
@pytest.fixture(autouse=True)
def mock_services():
    # Mock para la función send_tracking_event
    with patch(
        "shipping_order_service.app.services.tracking_service_client"
        ".send_tracking_event",
        new_callable=AsyncMock,
    ) as mock_send:

        async def mock_coro(*args, **kwargs):
            return None

        mock_send.side_effect = mock_coro
        yield mock_send
