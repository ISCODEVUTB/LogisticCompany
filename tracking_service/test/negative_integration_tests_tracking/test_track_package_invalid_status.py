import pytest
import respx
from httpx import AsyncClient, Response


@pytest.mark.asyncio
async def test_track_package_invalid_status():
    payload = {"tracking_code": "TRK123456", "status": "flying"}  # Estado inválido

    with respx.mock() as mock:
        mock.post("https://test/api/events/track").mock(
            return_value=Response(status_code=422, json={"detail": "Invalid status"})
        )

        async with AsyncClient(base_url="https://test") as ac:
            response = await ac.post("/api/events/track", json=payload)

    assert response.status_code == 422
