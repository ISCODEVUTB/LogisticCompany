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


@router.post("/", response_model=ShippingOrderResponseDTO, status_code=201)
def create_order(order_data: ShippingOrderCreateDTO):
    return create_shipping_order(order_data)


@router.get("/{order_id}", response_model=ShippingOrderResponseDTO)
def get_order(order_id: str):
    order = get_shipping_order_by_id(order_id)
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    return order


@router.delete("/{order_id}", status_code=200)
def cancel_order(order_id: str):
    result = cancel_shipping_order(order_id)
    if not result:
        raise HTTPException(status_code=400, detail="Unable to cancel order")
    return {"message": "Order cancelled successfully"}


@router.patch("/{order_id}/status", status_code=200)
def update_order_status(order_id: str, status: str):
    result = update_shipping_order_status(order_id, status)
    if not result:
        raise HTTPException(status_code=400, detail="Unable to update order status")
    return {"message": f"Order status updated to '{status}'"}


@router.get("/track/{tracking_code}", response_model=ShippingOrderResponseDTO)
def track_order(tracking_code: str):
    order = track_shipping_order(tracking_code)
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    return order
