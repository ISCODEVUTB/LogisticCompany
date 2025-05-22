import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app # This should resolve to driver_service.app.main

@pytest.mark.asyncio
async def test_register_driver_success(): # Assuming original name was kept
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="https://test") as client:
        # Print registered routes
        print("Registered routes in test_register_driver_success:")
        for route in app.routes:
            print(f"  Path: {getattr(route, 'path', 'N/A')}, Name: {getattr(route, 'name', 'N/A')}, Methods: {getattr(route, 'methods', [])}")
            if hasattr(route, 'routes') and route.routes: # For APIRouter instances
                 for sub_route in route.routes:
                      print(f"    Sub-Path: {getattr(sub_route, 'path', 'N/A')}, Sub-Name: {getattr(sub_route, 'name', 'N/A')}, Sub-Methods: {getattr(sub_route, 'methods', [])}")


        payload = {
            "name": "Test Driver Minimal",
            "license_id": "TDMIN123",
            "phone": "1234567890"
        }
        response = await client.post("/drivers/", json=payload)
        print(f"Simplified test_register_driver - Response status: {response.status_code}")
        print(f"Simplified test_register_driver - Response content: {response.text}")
        assert response.status_code != 404
