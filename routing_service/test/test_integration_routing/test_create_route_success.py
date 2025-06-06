import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from unittest.mock import patch, AsyncMock

@pytest.mark.asyncio
async def test_create_route_success():
    # Definir funciones mock asíncronas para todas las dependencias
    async def mock_validate_driver(*args, **kwargs):
        return True
        
    async def mock_validate_orders(*args, **kwargs):
        return True
    
    async def mock_notify_driver_assignment(*args, **kwargs):
        return True
        
    async def mock_update_order_statuses(*args, **kwargs):
        return True
    
    # Aplicar todos los mocks necesarios
    with patch("app.api.routes.validate_driver", side_effect=mock_validate_driver) as mock_validate_driver, \
         patch("app.api.routes.validate_orders", side_effect=mock_validate_orders) as mock_validate_orders, \
         patch("app.api.routes.notify_driver_assignment", side_effect=mock_notify_driver_assignment) as mock_notify_driver, \
         patch("app.api.routes.update_order_statuses", side_effect=mock_update_order_statuses) as mock_update_orders:
        
        # Crear el cliente después de los mocks
        async with AsyncClient(transport=ASGITransport(app=app), base_url="https://test") as client:
            payload = {
                "origin": "Central Hub",
                "destination": "North Branch",
                "estimated_time": 120, # Example value
                "distance_km": 25.0,   # Example value
                "driver_id": "driver123",
                "order_ids": ["order1", "order2"]
            }
            
            # Realizar la solicitud dentro del contexto del cliente
            response = await client.post("/routes/", json=payload)
            
            # Realizar las aserciones dentro del mismo contexto
            assert response.status_code == 200
            data = response.json()
            assert data["origin"] == "Central Hub"
            assert data["driver_id"] == "driver123"
            assert "id" in data


