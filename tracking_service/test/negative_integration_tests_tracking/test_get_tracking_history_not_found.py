import pytest
import respx
from httpx import AsyncClient, Response

@pytest.mark.asyncio
async def test_get_tracking_history_not_found( ):
    with respx.mock() as mock:
        mock.get("https://test/tracking/track/NOCODE123" ).mock(
            return_value=Response(
                status_code=404,
                json={"detail": "Tracking code not found"}
            )
        )
        
        async with AsyncClient(base_url="https://test" ) as ac:
            response = await ac.get("/tracking/track/NOCODE123")
            
    assert response.status_code == 404
    assert response.json()["detail"] == "Tracking code not found"


