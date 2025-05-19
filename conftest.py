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

@pytest.fixture(autouse=True )
def mock_tracking_service():
    with unittest.mock.patch('app.services.tracking_service_client.send_tracking_event') as mock_send:
        with unittest.mock.patch('httpx.AsyncClient.post' ) as mock_post:
            async def mock_coro(*args, **kwargs):
                return None
                
            async def mock_response(*args, **kwargs):
                mock_resp = unittest.mock.MagicMock()
                mock_resp.status_code = 200
                mock_resp.json.return_value = {"status": "success"}
                return mock_resp
                
            mock_send.side_effect = mock_coro
            mock_post.side_effect = mock_response
            
            yield mock_send
