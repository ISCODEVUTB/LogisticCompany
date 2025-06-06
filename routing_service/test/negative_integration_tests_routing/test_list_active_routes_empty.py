import pytest
from httpx import AsyncClient
from routing_service.app.main import app
from httpx import ASGITransport

@pytest.mark.asyncio
async def test_list_active_routes_empty():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Clear all existing routes
        get_response = await client.get("/api/routes/")
        assert get_response.status_code == 200 # Ensure fetching routes is successful
        all_routes = get_response.json()
        
        for route in all_routes:
            route_id = route.get("id")
            if route_id:
                delete_response = await client.delete(f"/api/routes/{route_id}")
                # Optional: Check if delete was successful or route already gone
                assert delete_response.status_code in [200, 404]

        # Now, get active routes
        response = await client.get("/api/routes/active")

        assert response.status_code == 200
        assert response.json() == []  # La lista debe estar vacía
