routes_db = []
counter = 1

def create_route(route_data):
    global counter
    new_route = {
        "id": counter,
        "origin": route_data.origin,
        "destination": route_data.destination,
        "estimated_time": route_data.estimated_time,
        "distance_km": route_data.distance_km,
        "created_at": datetime.utcnow()
    }
    routes_db.append(new_route)
    counter += 1
    return new_route

def get_all_routes():
    return routes_db

def delete_route(route_id: int):
    global routes_db
    for r in routes_db:
        if r["id"] == route_id:
            routes_db.remove(r)
            return True
    return False
