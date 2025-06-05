import httpx
from fastapi import APIRouter, HTTPException
from app.schemas.shipping_order_schema import (
    ShippingOrderCreateDTO,
    ShippingOrderResponseDTO
)
from app.services.shipping_order_service import (
    create_shipping_order,
    get_shipping_order_by_id,
    cancel_shipping_order,
    update_shipping_order_status,
    track_shipping_order,
    get_all_shipping_orders
)

router = APIRouter()


@router.post("/orders", response_model=ShippingOrderResponseDTO, status_code=201)
async def create_order(dto: ShippingOrderCreateDTO):
    actual_dto_from_service = await create_shipping_order(dto)
    return actual_dto_from_service


@router.get("/orders/{order_id}", response_model=ShippingOrderResponseDTO)
def get_order(order_id: str):
    order = get_shipping_order_by_id(order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order


@router.post("/orders/{order_id}/cancel", status_code=204)
async def cancel_order(order_id: str):
    success = await cancel_shipping_order(order_id)
    if not success:
        raise HTTPException(status_code=400, detail="Unable to cancel the order")
    


@router.post("/orders/{order_id}/status", status_code=204)
async def update_status(order_id: str, status: str):
    success = update_shipping_order_status(order_id, status)
    if not success:
        raise HTTPException(status_code=400, detail="Unable to update order status")
    


@router.get("/orders/track/{tracking_code}", response_model=ShippingOrderResponseDTO)
def track_order(tracking_code: str):
    order = track_shipping_order(tracking_code)
    if not order:
        raise HTTPException(status_code=404, detail="Tracking code not found")
    return order


@router.get("/orders")
def list_orders():
    return get_all_shipping_orders()

import httpx

@router.get("/dashboard")
def dashboard():
    # Datos propios
    orders = get_all_shipping_orders()
    total_pedidos = len(orders)
    en_transito = sum(1 for o in orders if getattr(o, "status", None) == "en_transito")

    # Llamadas a otros microservicios
    try:
        drivers_resp = httpx.get("http://driver_service:8001/api/drivers", timeout=3)
        drivers = drivers_resp.json()
        conductores_disponibles = sum(1 for d in drivers if d.get("disponible", False))
        conductores_asignados = sum(1 for d in drivers if not d.get("disponible", False))
    except Exception:
        conductores_disponibles = 0
        conductores_asignados = 0

    try:
        rutas_resp = httpx.get("http://routing_service:8002/api/routes", timeout=3)
        rutas = rutas_resp.json()
        rutas_activas = sum(1 for r in rutas if r.get("activa", False))
    except Exception:
        rutas_activas = 0

    try:
        tracking_resp = httpx.get("http://tracking_service:8003/api/events", timeout=3)
        tracking_eventos = len(tracking_resp.json())
    except Exception:
        tracking_eventos = 0

    return {
        "pedidos": {"total": total_pedidos, "enTransito": en_transito},
        "conductores": {"disponibles": conductores_disponibles, "asignados": conductores_asignados},
        "rutas": {"activas": rutas_activas},
        "tracking": {"eventos": tracking_eventos}
    }