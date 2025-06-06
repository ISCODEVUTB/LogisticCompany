from app.repository.routing_repo import create_route, get_all_routes, delete_route, mark_route_completed, get_active_routes
from app.schemas.routing_schema import RouteCreate
from pydantic import BaseModel

class RouteService:
    def create(self, route_data: RouteCreate):
        if isinstance(route_data, BaseModel):
            payload = route_data.dict()
        else:
            payload = route_data # Assuming it's already a dict if not a BaseModel
        return create_route(payload)

    def get_all(self):
        return get_all_routes()

    def delete(self, route_id: str):
        return delete_route(route_id)

    def mark_as_completed(self, route_id: str) -> bool:
        return mark_route_completed(route_id)
    
    def get_active(self):
        return get_active_routes()
