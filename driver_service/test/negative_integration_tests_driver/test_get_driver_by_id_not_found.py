import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_get_driver_by_nonexistent_id():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        driver_id = "nonexistent-driver-xyz"

        response = await client.get(f"/drivers/{driver_id}")
        assert response.status_code == 404
        assert response.json()["detail"] == "Not found"
