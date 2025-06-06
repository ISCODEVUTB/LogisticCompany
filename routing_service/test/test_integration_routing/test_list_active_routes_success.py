import pytest
from httpx import AsyncClient, ASGITransport
from routing_service.app.main import app

@pytest.mark.asyncio
async def test_list_active_routes_success():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        response = await client.get("/api/routes/active")
        assert response.status_code == 200
        assert isinstance(response.json(), list)
