from fastapi import APIRouter, HTTPException

from ..schemas.driver_schema import (DriverCreateDTO, DriverResponseDTO,
                                     DriverUpdateDTO)
from ..services.driver_service import (assign_route, create_driver,
                                       deactivate_driver, get_driver,
                                       list_drivers, update_driver_data)

router = APIRouter()

DRIVER_NOT_FOUND = "Driver not found"


@router.post("/", response_model=DriverResponseDTO, status_code=201)
def register_driver(dto: DriverCreateDTO):
    return create_driver(dto)


@router.get("/{driver_id}", response_model=DriverResponseDTO)
def get_driver_by_id(driver_id: str):
    driver = get_driver(driver_id)
    if not driver:
        raise HTTPException(status_code=404, detail=DRIVER_NOT_FOUND)
    return driver


@router.get("/", response_model=list[DriverResponseDTO])
def get_all_drivers():
    return list_drivers()


@router.get("", response_model=list[DriverResponseDTO])
def get_all_drivers_alias():
    return list_drivers()


@router.patch("/{driver_id}", status_code=200)
def update_driver(driver_id: str, dto: DriverUpdateDTO):
    success = update_driver_data(driver_id, dto)
    if not success:
        raise HTTPException(status_code=404, detail=DRIVER_NOT_FOUND)
    return {"message": "Driver updated successfully"}


@router.delete("/{driver_id}", status_code=200)
def remove_driver(driver_id: str):
    success = deactivate_driver(driver_id)
    if not success:
        raise HTTPException(status_code=404, detail=DRIVER_NOT_FOUND)
    return {"message": "Driver deactivated"}


@router.patch("/{driver_id}/assign-route", status_code=200)
def assign_route_to_driver(driver_id: str, route_id: str):
    success = assign_route(driver_id, route_id)
    if not success:
        raise HTTPException(status_code=404, detail=DRIVER_NOT_FOUND)
    return {"message": f"Route {route_id} assigned to driver {driver_id}"}
