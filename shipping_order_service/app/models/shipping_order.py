from datetime import datetime, timezone
from typing import Optional


class ShippingOrder:
    def __init__(
        self,
        order_id: str,
        tracking_code: str,
        sender: dict,
        receiver: dict,
        pickup_date: datetime,
        package: dict,
        status: str = "created",
        delivery_date: Optional[datetime] = None,
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None
    ):
        self.order_id = order_id
        self.tracking_code = tracking_code
        self.sender = sender
        self.receiver = receiver
        self.pickup_date = pickup_date
        self.package = package
        self.status = status
        self.delivery_date = delivery_date
        self.created_at = created_at or datetime.now(timezone.utc)
        self.updated_at = updated_at or datetime.now(timezone.utc)
