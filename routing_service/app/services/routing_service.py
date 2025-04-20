from app.repository.routing_repo import create_route, get_all_routes, delete_route, mark_route_completed, get_active_routes
from app.schemas.routing_schema import RouteCreate

class RouteService:
    def create(self, route_data: RouteCreate):
        return create_route(route_data)

    def get_all(self):
        return get_all_routes()

    def delete(self, route_id: str):
        return delete_route(route_id)

    def mark_as_completed(self, route_id: str) -> bool:
        return mark_route_completed(route_id)
    
    def get_active(self):
        return get_active_routes()