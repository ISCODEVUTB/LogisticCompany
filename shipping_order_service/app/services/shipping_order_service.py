import uuid
from datetime import datetime

from app.models.shipping_order import ShippingOrder
from app.schemas.shipping_order_schema import (
    ShippingOrderCreateDTO,
    ShippingOrderResponseDTO
)
from app.repository.shipping_order_repo import (
    save_order,
    get_order_by_id,
    get_order_by_tracking_code,
    update_order_status,
    cancel_order
)


def generate_tracking_code() -> str:
    return f"TRK-{uuid.uuid4().hex[:10].upper()}"


def create_shipping_order(dto: ShippingOrderCreateDTO) -> ShippingOrderResponseDTO:
    order_id = str(uuid.uuid4())
    tracking_code = generate_tracking_code()

    order = ShippingOrder(
        order_id=order_id,
        tracking_code=tracking_code,
        sender=dto.sender.dict(),
        receiver=dto.receiver.dict(),
        pickup_date=dto.pickup_date,
        package=dto.package.dict(),
        status="created"
    )

    save_order(order)

    return ShippingOrderResponseDTO(
        order_id=order.order_id,
        tracking_code=order.tracking_code,
        status=order.status,
        created_at=order.created_at
    )


def get_shipping_order_by_id(order_id: str) -> ShippingOrderResponseDTO | None:
    order = get_order_by_id(order_id)
    if order is None:
        return None

    return ShippingOrderResponseDTO(
        order_id=order.order_id,
        tracking_code=order.tracking_code,
        status=order.status,
        created_at=order.created_at
    )


def cancel_shipping_order(order_id: str) -> bool:
    return cancel_order(order_id)


def update_shipping_order_status(order_id: str, status: str) -> bool:
    return update_order_status(order_id, status)


def track_shipping_order(tracking_code: str) -> ShippingOrderResponseDTO | None:
    order = get_order_by_tracking_code(tracking_code)
    if order is None:
        return None

    return ShippingOrderResponseDTO(
        order_id=order.order_id,
        tracking_code=order.tracking_code,
        status=order.status,
        created_at=order.created_at
    )
