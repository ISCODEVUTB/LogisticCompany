from app.services.routing_service import RouteService
from app.schemas.routing_schema import RouteCreate

def test_create_route_success():
    # Arrange
    service = RouteService()
    data = RouteCreate(
        origin="Bodega Central",
        destination="Sucursal Norte",
        estimated_time=45,
        distance_km=12.5,
        driver_id=None,
        order_ids=[]
    )

    # Act
    route = service.create(data)

    # Assert
    assert route["id"] is not None
    assert route["origin"] == "Bodega Central"
    assert route["destination"] == "Sucursal Norte"
    assert route["status"] == "in_progress"
