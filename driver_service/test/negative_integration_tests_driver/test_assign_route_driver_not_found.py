import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_assign_route_to_nonexistent_driver():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        driver_id = "nonexistent-driver-abc"
        route_id = "route-001"

        response = await client.patch(f"/drivers/{driver_id}/assign-route", params={"route_id": route_id})
        assert response.status_code == 404
        assert response.json()["detail"] == "Not Found"
