import uuid
from datetime import datetime
from app.models.driver import Driver
from app.schemas.driver_schema import (
    DriverCreateDTO,
    DriverUpdateDTO,
    DriverResponseDTO
)
from app.repository.driver_repo import (
    save_driver,
    get_driver_by_id,
    get_all_drivers,
    update_driver,
    delete_driver
)


def create_driver(dto: DriverCreateDTO) -> DriverResponseDTO:
    driver_id = str(uuid.uuid4())

    driver = Driver(
        driver_id=driver_id,
        name=dto.name,
        license_id=dto.license_id,
        phone=dto.phone,
        status="available"
    )

    save_driver(driver)

    return DriverResponseDTO(
        driver_id=driver.driver_id,
        name=driver.name,
        license_id=driver.license_id,
        phone=driver.phone,
        status=driver.status,
        created_at=driver.created_at,
        updated_at=driver.updated_at
    )


def get_driver(driver_id: str) -> DriverResponseDTO | None:
    driver = get_driver_by_id(driver_id)
    if driver is None:
        return None

    return DriverResponseDTO(**driver.__dict__)


def list_drivers() -> list[DriverResponseDTO]:
    drivers = get_all_drivers()
    return [DriverResponseDTO(**d.__dict__) for d in drivers]


def update_driver_data(driver_id: str, dto: DriverUpdateDTO) -> bool:
    updates = {k: v for k, v in dto.dict().items() if v is not None}
    return update_driver(driver_id, updates)


def deactivate_driver(driver_id: str) -> bool:
    return delete_driver(driver_id)
