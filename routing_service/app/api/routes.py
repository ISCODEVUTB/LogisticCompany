from fastapi import APIRouter, HTTPException
from typing import List
from app.schemas.routing_schema import RouteCreate, RouteOut, RouteDriverUpdate
from app.services.routing_service import RouteService
from app.core.validators import (
    validate_driver,
    validate_orders,
    notify_driver_assignment,
    update_order_statuses
)

router = APIRouter()
service = RouteService()

@router.post("/routes/", response_model=RouteOut)
async def create_route_endpoint(data: RouteCreate):
    # Validación de existencia de conductor
    if data.driver_id and not await validate_driver(data.driver_id):
        raise HTTPException(status_code=400, detail="Driver not found")

    # Validación de existencia de pedidos
    if data.order_ids and not await validate_orders(data.order_ids):
        raise HTTPException(status_code=400, detail="One or more orders not found")

    # Crear la ruta localmente
    route = service.create(data)

    # Notificar al servicio de conductores
    if data.driver_id:
        success = await notify_driver_assignment(data.driver_id, route["id"])
        if not success:
            raise HTTPException(status_code=500, detail="Failed to assign route to driver")

    # Actualizar estado de pedidos
    if data.order_ids:
        success = await update_order_statuses(data.order_ids, status="assigned")
        if not success:
            raise HTTPException(status_code=500, detail="Failed to update order statuses")

    return route


@router.get("/routes/", response_model=List[RouteOut])
def list_routes():
    return service.get_all()


@router.delete("/routes/{route_id}")
def delete_route(route_id: str):
    if service.delete(route_id):
        return {"message": f"Route {route_id} deleted"}
    raise HTTPException(status_code=404, detail="Route not found")

@router.patch("/routes/{route_id}/complete")
async def complete_route(route_id: str):
    # Buscar ruta
    routes = service.get_all()
    route = next((r for r in routes if r["id"] == route_id), None)

    if not route:
        raise HTTPException(status_code=404, detail="Route not found")

    # Actualizar estado de órdenes
    if route["order_ids"]:
        success = await update_order_statuses(route["order_ids"], status="delivered")
        if not success:
            raise HTTPException(status_code=500, detail="Failed to update order statuses")

    # Notificar al driver_service que está disponible
    if route.get("driver_id"):
        notify_success = await notify_driver_assignment(route["driver_id"], None)  # limpiamos asignación
        if not notify_success:
            raise HTTPException(status_code=500, detail="Failed to update route")

    # Actualizar el estado de la ruta a 'completed'
    updated = service.mark_as_completed(route_id)
    if not updated:
        raise HTTPException(status_code=500, detail="Failed to update route")

    return {"message": f"Route {route_id} completed successfully"}

@router.get("/routes/active", response_model=List[RouteOut])
def list_active_routes():
    return service.get_active()

@router.patch("/routes/{route_id}/driver", response_model=RouteOut)
async def assign_driver_to_route_endpoint(route_id: str, payload: RouteDriverUpdate):
    return await service.assign_driver_to_route(route_id, payload.driver_id)
