import uuid
from datetime import datetime
from app.repository.shipping_order_repo import get_all_orders

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
from app.services.tracking_service_client import send_tracking_event


async def create_shipping_order(dto: ShippingOrderCreateDTO) -> ShippingOrderResponseDTO:
    order_id = str(uuid.uuid4()) # Assuming uuid is imported
    tracking_code = generate_tracking_code() # Assuming this function exists

    order = ShippingOrder( # Assuming ShippingOrder model is imported
        order_id=order_id,
        tracking_code=tracking_code,
        sender=dto.sender.dict(),
        receiver=dto.receiver.dict(),
        pickup_date=dto.pickup_date,
        package=dto.package.dict(),
        status="created"
        # created_at is often set by default in the model or DB
    )
    # Ensure created_at is set if not defaulted, e.g.:
    # if not hasattr(order, 'created_at') or not order.created_at:
    #    order.created_at = datetime.now() # Assuming datetime is imported

    save_order(order) # Assuming save_order is imported

    # Call send_tracking_event, its result (now a dict) must not be returned by this function
    await send_tracking_event(order.tracking_code, "created", order.created_at if hasattr(order, 'created_at') and order.created_at else datetime.now(tz=datetime.timezone.utc))

    # Construct the DTO that this function MUST return
    response_to_return = ShippingOrderResponseDTO(
        order_id=order.order_id,
        tracking_code=order.tracking_code,
        status=order.status,
        created_at=order.created_at if hasattr(order, 'created_at') and order.created_at else datetime.now(tz=datetime.timezone.utc) # Ensure created_at is available
    )
    return response_to_return


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


def generate_tracking_code() -> str:
    return f"TRK-{uuid.uuid4().hex[:10].upper()}"

def get_all_shipping_orders():
    orders = get_all_orders()  # Debe devolver una lista de ShippingOrder
    return [
        ShippingOrderResponseDTO(
            order_id=o.order_id,
            tracking_code=o.tracking_code,
            status=o.status,
            created_at=o.created_at
        )
        for o in orders
    ]
