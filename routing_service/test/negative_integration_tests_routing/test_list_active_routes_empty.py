import pytest
from httpx import AsyncClient
from app.main import app
from httpx import ASGITransport

@pytest.mark.asyncio
async def test_list_active_routes_empty():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        response = await client.get("/routes/active")

        assert response.status_code == 200
        assert response.json() == []  # La lista debe estar vacía
