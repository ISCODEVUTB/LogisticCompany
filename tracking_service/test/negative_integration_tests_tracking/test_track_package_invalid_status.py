import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_track_package_invalid_status():
    payload = {
        "tracking_code": "TRK123456",
        "status": "flying"  # Estado inválido
    }
    async with AsyncClient(base_url="https://test") as ac:
        response = await ac.post("/tracking/track", json=payload)
    assert response.status_code == 422
