import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_get_tracking_history_not_found():
    async with AsyncClient(base_url="https://test") as ac:
        response = await ac.get("/tracking/track/NOCODE123")
    assert response.status_code == 404
    assert response.json()["detail"] == "Tracking code not found"
