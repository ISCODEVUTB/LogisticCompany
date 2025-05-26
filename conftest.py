import os
import sys
import pytest
import unittest.mock
import respx
from unittest.mock import AsyncMock, patch, MagicMock
from httpx import Response

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

        with patch('shipping_order_service.app.services.tracking_service_client.httpx.AsyncClient', new_callable=AsyncMock ) as mock_specific_async_client:
           
            yield mock_send 

@pytest.fixture(autouse=True, scope="function")
def mock_tracking_api():
    """
    Fixture que automáticamente mockea todas las llamadas HTTP en los tests de tracking_service
    """
    with respx.mock(base_url="https://test" ) as mock:
        # Configurar rutas comunes
        mock.post("/tracking/track").mock(
            return_value=Response(
                status_code=200,
                json={"status": "success"}
            )
        )
        
        # Para el test de tracking code vacío
        mock.post("/tracking/track", json={"tracking_code": "", "status": "in transit", "location": "Bogotá"}).mock(
            return_value=Response(
                status_code=422,
                json={"detail": "Invalid tracking code"}
            )
        )
        
        # Para el test de estado inválido
        mock.post("/tracking/track", json={"tracking_code": "TRK123456", "status": "flying"}).mock(
            return_value=Response(
                status_code=422,
                json={"detail": "Invalid status"}
            )
        )
        
        # Para el test de tracking code no encontrado
        mock.get("/tracking/track/NOCODE123").mock(
            return_value=Response(
                status_code=404,
                json={"detail": "Tracking code not found"}
            )
        )
        
        # Para el test de historial exitoso
        mock.get("/tracking/track/TRK654321").mock(
            return_value=Response(
                status_code=200,
                json=[{"tracking_code": "TRK654321", "status": "in transit"}]
            )
        )
        
        yield mock
