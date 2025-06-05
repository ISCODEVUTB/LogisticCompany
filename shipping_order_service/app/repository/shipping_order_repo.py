import json
from pathlib import Path
from typing import Optional, Dict
from app.models.shipping_order import ShippingOrder
from datetime import datetime

# Ruta del archivo JSON
DB_FILE = Path("app/repository/orders.json")


def load_orders() -> Dict[str, dict]:
    if DB_FILE.exists():
        with DB_FILE.open("r", encoding="utf-8") as file:
            return json.load(file)
    return {}


def save_orders(data: Dict[str, dict]):
    def default_serializer(obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        return str(obj)

    with DB_FILE.open("w", encoding="utf-8") as file:
        json.dump(data, file, indent=4, ensure_ascii=False, default=default_serializer)



def save_order(order: ShippingOrder):
    orders = load_orders()
    orders[order.order_id] = order.__dict__
    save_orders(orders)


def get_order_by_id(order_id: str) -> Optional[ShippingOrder]:
    orders = load_orders()
    order_data = orders.get(order_id)
    if order_data:
        return ShippingOrder(**order_data)
    return None


def get_order_by_tracking_code(tracking_code: str) -> Optional[ShippingOrder]:
    orders = load_orders()
    for data in orders.values():
        if data["tracking_code"] == tracking_code:
            return ShippingOrder(**data)
    return None


def update_order_status(order_id: str, status: str) -> bool:
    orders = load_orders()
    order_data = orders.get(order_id)
    if order_data:
        order_data["status"] = status
        save_orders(orders)
        return True
    return False


def cancel_order(order_id: str) -> bool:
    orders = load_orders()
    order_data = orders.get(order_id)
    if order_data and order_data["status"] == "created":
        order_data["status"] = "cancelled"
        save_orders(orders)
        return True
    return False


def get_all_orders():
    orders = load_orders()
    return [ShippingOrder(**data) for data in orders.values()]
