@pytest.mark.asyncio
async def test_track_shipping_order_by_code():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Crear orden
        payload = {
            "sender": {"name": "Laura Ríos", "address": "Carrera 45", "phone": "3105678901"},
            "receiver": {"name": "Pedro Quintero", "address": "Calle 77", "phone": "3211234567"},
            "pickup_date": "2025-05-05T18:00:00",
            "package": {"weight": 4.0, "dimensions": "40x40x40"}
        }
        response = await client.post("/orders", json=payload)
        tracking_code = response.json()["tracking_code"]

        # Rastrear
        track_response = await client.get(f"/orders/track/{tracking_code}")
        assert track_response.status_code == 200
        data = track_response.json()
        assert data["tracking_code"] == tracking_code
