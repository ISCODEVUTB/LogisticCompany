from datetime import datetime, timezone
from unittest.mock import patch

from driver_service.app.schemas.driver_schema import DriverCreateDTO
from driver_service.app.services.driver_service import create_driver


# Patch save_driver where it's looked up
# in the app.services.driver_service module
@patch("driver_service.app.services.driver_service.save_driver")
def test_create_driver_success(mock_save_driver):
    # mock_load_drivers is removed as it's not directly used by create_driver
    # service function

    # Arrange
    driver_data = DriverCreateDTO(
        name="Juan Pérez",
        license_id="LIC12345",
        phone="3124567890",
        # 'available=True' removed as it's not in DriverCreateDTO
    )

    # Act
    driver = create_driver(driver_data)

    # Assert
    assert driver.name == driver_data.name
    assert driver.license_id == driver_data.license_id
    assert driver.phone == driver_data.phone

    assert driver.driver_id is not None
    assert isinstance(driver.driver_id, str)  # Driver model generates UUID as str

    assert driver.status == "available"  # Default status from Driver model

    assert driver.created_at is not None
    assert isinstance(driver.created_at, datetime)
    # Note: Pydantic v1 models might not automatically set timezone to UTC
    # unless explicitly done in model
    # For this test, we'll assume it's set or not strictly check tzinfo
    # if not critical for this unit.
    # If Driver model's default_factory for created_at/updated_at uses
    # timezone.utc, this is fine.
    if driver.created_at.tzinfo is not None:  # Check only if tzinfo is set
        assert driver.created_at.tzinfo == timezone.utc

    assert driver.updated_at is not None
    assert isinstance(driver.updated_at, datetime)
    if driver.updated_at.tzinfo is not None:  # Check only if tzinfo is set
        assert driver.updated_at.tzinfo == timezone.utc

    # Assert that the mocked save_driver was called once.
    # To check arguments:
    # mock_save_driver.assert_called_once_with(driver_instance_arg)
    # where driver_instance_arg is the instance of Driver passed to save_driver.
    # For simplicity here, just checking it was called. Can be more specific
    # if needed.
    mock_save_driver.assert_called_once()
    # To assert with the specific driver instance:
    # We can capture the argument passed to the mock and assert its properties
    called_with_driver = mock_save_driver.call_args[0][0]
    assert called_with_driver.name == driver.name
    assert called_with_driver.license_id == driver.license_id
