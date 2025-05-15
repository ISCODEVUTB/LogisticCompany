from datetime import datetime, timezone

class Driver:
    def __init__(
        self,
        driver_id: str,
        name: str,
        license_id: str,
        phone: str,
        status: str = "available",
        created_at: datetime = None,
        updated_at: datetime = None
    ):
        self.driver_id = driver_id
        self.name = name
        self.license_id = license_id
        self.phone = phone
        self.status = status
        self.created_at = created_at or datetime.now(timezone.utc)
        self.updated_at = updated_at or datetime.now(timezone.utc)
