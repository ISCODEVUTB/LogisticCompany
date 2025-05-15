import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_deactivate_nonexistent_driver():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        driver_id = "nonexistent-id-999"

        response = await client.delete(f"/drivers/{driver_id}")
        assert response.status_code == 404
        assert response.json()["detail"] == "Not Found"
