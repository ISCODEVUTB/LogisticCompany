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
        # Mock para AsyncClient desde httpx
        with patch('httpx.AsyncClient') as mock_client_class:
            # Mock para AsyncClient desde httpx._transports.asgi (por si acaso)
            with patch('httpx._transports.asgi.AsyncClient', mock_client_class):
                # Mock para ASGITransport
                with patch('httpx.ASGITransport') as mock_transport:
                    with patch('httpx._transports.asgi.ASGITransport', mock_transport):
                        # Configurar el mock de AsyncClient
                        mock_instance = AsyncMock()
                        mock_response = AsyncMock()
                        mock_response.status_code = 200
                        mock_response.json.return_value = {"status": "success"}
                        mock_instance.post.return_value = mock_response
                        mock_instance.get.return_value = mock_response
                        mock_instance.patch.return_value = mock_response
                        mock_instance.delete.return_value = mock_response
                        mock_client_class.return_value = mock_instance
                        
                        # Configurar el mock de send_tracking_event
                        async def mock_coro(*args, **kwargs):
                            return None
                        mock_send.side_effect = mock_coro
                        
                        yield mock_send
