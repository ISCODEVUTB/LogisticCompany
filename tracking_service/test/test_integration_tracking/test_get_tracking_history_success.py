import pytest
import httpx

@pytest.mark.asyncio
async def test_get_tracking_history_success():
    # Primero, se registra un evento de rastreo
    async with httpx.AsyncClient(base_url="https://test") as client:
        await client.post("/tracking/track", json={
            "tracking_code": "TRK654321",
            "location": "Medellín",
            "status": "Recibido en bodega",
            "timestamp": "2024-05-02T08:30:00"
        })

        # Luego, se consulta el historial por el tracking code
        response = await client.get("/tracking/track/TRK654321")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert any(event["tracking_code"] == "TRK654321" for event in data)
