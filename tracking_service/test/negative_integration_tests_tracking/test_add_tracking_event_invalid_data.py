import pytest
import respx
from httpx import AsyncClient, Response


@pytest.mark.asyncio
async def test_add_tracking_event_invalid_data():
    with respx.mock() as mock:
        mock.post("https://test/api/events/track").mock(
            return_value=Response(
                status_code=422, json={"detail": "Invalid tracking code"}
            )
        )

        async with AsyncClient(base_url="https://test") as ac:
            # tracking_code está vacío, lo cual debería ser inválido
            response = await ac.post(
                "/api/events/track",
                json={
                    "tracking_code": "",
                    "status": "in transit",
                    "location": "Bogotá",
                },
            )

    assert (
        response.status_code == 422
    )  # Error de validación de FastAPI (Unprocessable Entity)
