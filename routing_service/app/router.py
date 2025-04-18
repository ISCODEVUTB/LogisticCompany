from fastapi import APIRouter, HTTPException
from typing import List
from schemas.route_schema import RouteCreate, RouteOut
from services.route_service import RouteService

router = APIRouter()
service = RouteService()

@router.post("/routes/", response_model=RouteOut)
def create_route_endpoint(data: RouteCreate):
    return service.create(data)

@router.get("/routes/", response_model=List[RouteOut])
def list_routes():
    return service.get_all()

@router.delete("/routes/{route_id}")
def delete_route(route_id: int):
    if service.delete(route_id):
        return {"message": f"Route {route_id} deleted"}
    raise HTTPException(status_code=404, detail="Route not found")
