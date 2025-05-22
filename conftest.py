import os
import sys
import pytest
import unittest.mock
from unittest.mock import AsyncMock, patch, MagicMock

root_dir = os.path.abspath(os.path.dirname(__file__))
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

        # This new patch specifically targets the AsyncClient used by the tracking_service_client.
        # The individual integration tests for shipping_order_service already provide
        # more detailed mocks for this specific path when they need to control responses
        # from the tracking service. This conftest.py mock primarily ensures that no
        # actual HTTP calls are made by the tracking_service_client if a test doesn't
        # provide its own specific mock for it.
        with patch('shipping_order_service.app.services.tracking_service_client.httpx.AsyncClient', new_callable=AsyncMock) as mock_specific_async_client:
            # We can configure basic behavior for mock_specific_async_client if needed,
            # e.g., mock_specific_async_client.return_value.post.return_value = AsyncMock(status_code=200, json=lambda: {"status": "mocked in conftest"})
            # However, since tests re-mock this, a plain AsyncMock is likely sufficient.
            yield mock_send # Yielding only mock_send as per original behavior
