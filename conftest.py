import os
import sys
import pytest
import unittest.mock

root_dir = os.path.abspath(os.path.dirname(__file__))
sys.path.insert(0, root_dir)
sys.path.insert(0, os.path.join(root_dir, 'routing_service'))
sys.path.insert(0, os.path.join(root_dir, 'driver_service'))
sys.path.insert(0, os.path.join(root_dir, 'shipping_order_service'))
sys.path.insert(0, os.path.join(root_dir, 'tracking_service'))

# Mock para evitar llamadas reales al servicio de tracking
@pytest.fixture(autouse=True)
def mock_tracking_service():
    with unittest.mock.patch('app.services.shipping_order_service.send_tracking_event') as mock:
        # Configuramos el mock para que devuelva una corrutina que no hace nada
        async def mock_coro(*args, **kwargs):
            return None
        mock.side_effect = mock_coro
        yield mock
