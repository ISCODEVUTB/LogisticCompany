import httpx

DRIVER_SERVICE_URL = "http://localhost:8001/drivers"
ORDER_SERVICE_URL = "http://localhost:8002/orders"

async def validate_driver(driver_id: str) -> bool:
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{DRIVER_SERVICE_URL}/{driver_id}")
            return response.status_code == 200
    except Exception:
        return False

async def validate_orders(order_ids: list[str]) -> bool:
    try:
        async with httpx.AsyncClient() as client:
            for order_id in order_ids:
                response = await client.get(f"{ORDER_SERVICE_URL}/{order_id}")
                if response.status_code != 200:
                    return False
        return True
    except Exception:
        return False

# core/validators.py
async def notify_driver_assignment(driver_id: str, route_id: str) -> bool:
    try:
        async with httpx.AsyncClient() as client:
            response = await client.patch(
                f"{DRIVER_SERVICE_URL}/{driver_id}/assign-route",
                params={"route_id": route_id}
            )
            return response.status_code == 200
    except Exception:
        return False

async def update_order_statuses(order_ids: list[str], status: str = "assigned") -> bool:
    try:
        async with httpx.AsyncClient() as client:
            for order_id in order_ids:
                response = await client.patch(
                    f"{ORDER_SERVICE_URL}/{order_id}/status",
                    params={"status": status}
                )
                if response.status_code != 200:
                    return False
        return True
    except Exception:
        return False
