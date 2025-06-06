import json
from datetime import datetime, timezone
from pathlib import Path
import uuid

DB_FILE = Path("app/repository/routes.json")

if not DB_FILE.parent.exists():
    DB_FILE.parent.mkdir(parents=True, exist_ok=True)

def load_routes():
    if DB_FILE.exists():
        with DB_FILE.open("r", encoding="utf-8") as f:
            return json.load(f)
    return {}

def save_routes(data):
    with DB_FILE.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=4, ensure_ascii=False, default=str)

def create_route(route_data):
    routes = load_routes()
    route_id = str(uuid.uuid4())
    new_route = {
        "id": route_id,
        "origin": route_data['origin'],
        "destination": route_data['destination'],
        "estimated_time": route_data['estimated_time'],
        "distance_km": route_data['distance_km'],
        "driver_id": route_data['driver_id'],
        "order_ids": route_data['order_ids'],
        "created_at": datetime.now(timezone.utc).isoformat(),
        "status": "in_progress"
    }
    routes[route_id] = new_route
    save_routes(routes)
    return new_route

def get_all_routes():
    return list(load_routes().values())

def delete_route(route_id: str):
    routes = load_routes()
    if route_id in routes:
        del routes[route_id]
        save_routes(routes)
        return True
    return False

def mark_route_completed(route_id: str) -> bool:
    routes = load_routes()
    if route_id in routes:
        routes[route_id]["status"] = "completed"
        save_routes(routes)
        return True
    return False

def get_active_routes():
    routes = load_routes()
    return [route for route in routes.values() if route.get("status") != "completed"]
