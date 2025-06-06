import pytest
import respx
from httpx import AsyncClient, Response

@pytest.mark.asyncio
async def test_track_package_missing_fields( ):
    with respx.mock() as mock:
        mock.post("https://test/tracking/track" ).mock(
            return_value=Response(
                status_code=422,
                json={"detail": "Missing required fields"}
            )
        )
        
        async with AsyncClient(base_url="https://test" ) as ac:
            # Falta tracking_code y status
            response = await ac.post("/tracking/track", json={})
            
    assert response.status_code == 422
