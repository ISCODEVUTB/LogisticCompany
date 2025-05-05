import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_track_package_missing_fields():
    async with AsyncClient(base_url="https://test") as ac:
        # Falta tracking_code y status
        response = await ac.post("/tracking/track", json={})
    assert response.status_code == 422
