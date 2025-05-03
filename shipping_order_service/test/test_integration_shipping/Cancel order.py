@pytest.mark.asyncio
async def test_cancel_shipping_order():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Crear orden
        payload = {
            "sender": {"name": "Luis Díaz", "address": "Calle Falsa 123", "phone": "3001112233"},
            "receiver": {"name": "Ana Ruiz", "address": "Av Central 456", "phone": "3114445566"},
            "pickup_date": "2025-05-04T15:00:00",
            "package": {"weight": 1.2, "dimensions": "15x10x5"}
        }
        response = await client.post("/orders", json=payload)
        order_id = response.json()["order_id"]

        # Cancelar
        cancel_response = await client.post(f"/orders/{order_id}/cancel")
        assert cancel_response.status_code == 204
