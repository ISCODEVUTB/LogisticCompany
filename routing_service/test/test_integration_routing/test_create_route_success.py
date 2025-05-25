import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from unittest.mock import patch

@pytest.mark.asyncio
async def test_create_route_success():
    # Mover la creación del cliente dentro del contexto de los mocks
    # para asegurar que esté disponible cuando se necesite
    with patch("app.api.routes.validate_driver", return_value=True) as mock_validate_driver, \
         patch("app.api.routes.validate_orders", return_value=True) as mock_validate_orders:
        
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
