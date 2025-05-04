import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_create_route_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        payload = {
            "driver_id": "driver123", 
            "order_ids": ["order1", "order2"],  
            "route_name": "Ruta Norte"
        }

        response = await client.post("/routes/", json=payload)

        assert response.status_code == 200
        data = response.json()
        assert data["route_name"] == "Ruta Norte"
        assert data["driver_id"] == "driver123"
        assert "id" in data
