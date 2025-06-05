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
    track_shipping_order
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
