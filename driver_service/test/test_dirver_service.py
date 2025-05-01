import pytest
from app.services.driver_service import create_driver
from app.schemas.driver_schema import DriverCreateDTO

def test_create_driver_success():
    # Arrange
    driver_data = DriverCreateDTO(
        name="Juan Pérez",
        license_id="LIC12345",
        phone="3124567890",
        available=True
    )

    # Act
    driver = create_driver(driver_data)

    # Assert
    assert driver.name == "Juan Pérez"
    assert driver.license_id == "LIC12345"
    assert driver.phone == "3124567890"
    assert driver.driver_id is not None
    assert driver.created_at is not None
    assert driver.updated_at is not None
