import pytest
from httpx import AsyncClient
from app.main import app
from httpx import ASGITransport

@pytest.mark.asyncio
async def test_delete_route_not_found():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        fake_route_id = "nonexistent-route-id"

        response = await client.delete(f"/api/routes/{fake_route_id}")

        assert response.status_code == 404
    assert response.json()["detail"] == "Not Found"
