import os
import sys
import pytest
import unittest.mock
from unittest.mock import AsyncMock, patch, MagicMock

root_dir = os.path.abspath(os.path.dirname(__file__ ))
sys.path.insert(0, root_dir)
sys.path.insert(0, os.path.join(root_dir, 'routing_service'))
sys.path.insert(0, os.path.join(root_dir, 'driver_service'))
sys.path.insert(0, os.path.join(root_dir, 'shipping_order_service'))
sys.path.insert(0, os.path.join(root_dir, 'tracking_service'))

# Este fixture se aplicará a todos los tests automáticamente
@pytest.fixture(autouse=True)
def mock_services():
    # Mock para la función send_tracking_event
    with patch('shipping_order_service.app.services.tracking_service_client.send_tracking_event', new_callable=AsyncMock) as mock_send:
        async def mock_coro(*args, **kwargs):
            return None
        mock_send.side_effect = mock_coro

        # Aplicamos el patch pero no necesitamos usar la variable
        with patch('shipping_order_service.app.services.tracking_service_client.httpx.AsyncClient', new_callable=AsyncMock):
            yield mock_send

