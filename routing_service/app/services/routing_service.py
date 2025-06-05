from typing import Optional  # Added

from fastapi import HTTPException  # Added
from pydantic import BaseModel

from ..core.validators import (notify_driver_assignment,  # Added
                                 validate_driver)
from ..repository.routing_repo import get_route_by_id  # Added
from ..repository.routing_repo import update_route_driver_assignment  # Added
from ..repository.routing_repo import (create_route, delete_route,
                                         get_active_routes, get_all_routes,
                                         mark_route_completed)
from ..schemas.routing_schema import RouteCreate


class RouteService:
    def create(self, route_data: RouteCreate):
        if isinstance(route_data, BaseModel):
            payload = route_data.dict()
        else:
            payload = route_data  # Assuming it's already a dict if not a BaseModel
        return create_route(payload)

    def get_all(self):
        return get_all_routes()

    def delete(self, route_id: str):
        return delete_route(route_id)

    def mark_as_completed(self, route_id: str) -> bool:
        return mark_route_completed(route_id)

    def get_active(self):
        return get_active_routes()

    async def assign_driver_to_route(self, route_id: str, new_driver_id: str) -> dict:
        route = get_route_by_id(route_id)
        if not route:
            raise HTTPException(status_code=404, detail="Route not found")

        if not await validate_driver(new_driver_id):
            raise HTTPException(
                status_code=400, detail="New driver not found or invalid"
            )

        old_driver_id: Optional[str] = route.get("driver_id")

        updated_route = update_route_driver_assignment(route_id, new_driver_id)
        if not updated_route:
            # This case should ideally not happen if route was found before.
            raise HTTPException(
                status_code=500,
                detail="Failed to update route's driver assignment in repository",
            )

        if old_driver_id and old_driver_id != new_driver_id:
            if not await notify_driver_assignment(old_driver_id, None):
                # Log this failure, but proceed as the route's driver_id is
                # already updated.
                print(
                    f"Warning: Failed to notify old driver {old_driver_id} of unassignment from route {route_id}"
                )

        if new_driver_id:
            if not await notify_driver_assignment(new_driver_id, route_id):
                # This is a significant issue.
                raise HTTPException(
                    status_code=500,
                    detail=f"Route driver updated to {new_driver_id}, but failed to notify driver service.",
                )

        return updated_route
