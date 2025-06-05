import uuid
from datetime import datetime, timezone # Added timezone
import logging # Added

from app.models.shipping_order import ShippingOrder
from app.schemas.shipping_order_schema import (
    ShippingOrderCreateDTO,
    ShippingOrderResponseDTO
)
from app.repository.shipping_order_repo import (
    save_order,
    get_order_by_id,
    get_order_by_tracking_code,
    update_order_status as repo_update_order_status, # Aliased
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


async def cancel_shipping_order(order_id: str) -> bool:
    order_data = cancel_order(order_id)
    if order_data:
        tracking_code = order_data["tracking_code"]
        cancelled_status = order_data["status"] # Should be "cancelled"
        updated_at_iso = order_data["updated_at"]
        # Handle 'Z' for UTC timezone info if present
        updated_at_dt = datetime.fromisoformat(updated_at_iso.replace("Z", "+00:00"))
        await send_tracking_event(tracking_code, cancelled_status, updated_at_dt)
        return True
    return False


async def update_shipping_order_status(order_id: str, new_status: str) -> bool:
    logging.info(f"Attempting to update order ID: {order_id} to status: {new_status}")

    order_data = repo_update_order_status(order_id, new_status) # This is from shipping_order_repo.py

    if order_data is not None: # Explicitly check for None
        logging.info(f"Order ID: {order_id} found and updated in repo. Order data: {order_data}")
        try:
            tracking_code = order_data["tracking_code"]
            # Ensure updated_at is present and correctly formatted
            updated_at_iso = order_data.get("updated_at")
            if not updated_at_iso:
                logging.warning(f"updated_at not found for order {order_id} after update, using current time for tracking.")
                updated_at_dt = datetime.now(timezone.utc) # Fallback, though repo should set it
            else:
                # Handle potential 'Z' if FastAPI/Pydantic doesn't strip it for fromisoformat
                if isinstance(updated_at_iso, str) and updated_at_iso.endswith('Z'):
                    updated_at_iso = updated_at_iso[:-1] + "+00:00"
                elif isinstance(updated_at_iso, datetime): # If it's already a datetime obj
                    updated_at_dt = updated_at_iso
                    if updated_at_dt.tzinfo is None: # Ensure timezone aware
                         updated_at_dt = updated_at_dt.replace(tzinfo=timezone.utc)
                    updated_at_dt = updated_at_dt.astimezone(timezone.utc) # Normalize to UTC
                else: # Assuming it's an ISO string from the repo's json.dump logic
                    updated_at_dt = datetime.fromisoformat(updated_at_iso)


            logging.info(f"Sending tracking event for order ID: {order_id}, tracking_code: {tracking_code}, status: {new_status}")
            await send_tracking_event(tracking_code, new_status, updated_at_dt)
            logging.info(f"Tracking event sent for order ID: {order_id}")
            return True
        except Exception as e:
            logging.error(f"Error sending tracking event for order ID: {order_id} after status update: {e}", exc_info=True)
            # Decide if this should still return True as the order status was updated.
            # For now, let's say the primary operation (status update) succeeded.
            return True
    else:
        logging.info(f"Order ID: {order_id} not found in repo or not updated.")
        return False


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
