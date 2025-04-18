import pytest
from app.services.shipping_order_service import ShippingOrderService
from app.schemas.shipping_order_schema import ShippingOrderCreate, ShippingOrderUpdate
from app.models.shipping_order import ShippingOrder

@pytest.fixture
def service():
    # Instancia del servicio para cada prueba
    return ShippingOrderService()

def test_create_order(service):
    order_data = ShippingOrderCreate(
        customer_name="John Doe",
        product="Laptop",
        quantity=1,
        price=1000.00
    )
    new_order = service.create_order(order_data)
    assert new_order.id == 1  # El primer pedido debe tener el ID 1
    assert new_order.customer_name == "John Doe"
    assert new_order.product == "Laptop"
    assert new_order.quantity == 1
    assert new_order.price == 1000.00

def test_get_all_orders(service):
    # Crear un pedido
    order_data = ShippingOrderCreate(
        customer_name="Jane Smith",
        product="Smartphone",
        quantity=2,
        price=500.00
    )
    service.create_order(order_data)
    
    orders = service.get_all_orders()
    assert len(orders) == 1
    assert orders[0].customer_name == "Jane Smith"

def test_get_order_by_id(service):
    # Crear un pedido
    order_data = ShippingOrderCreate(
        customer_name="Alice Johnson",
        product="Tablet",
        quantity=3,
        price=300.00
    )
    new_order = service.create_order(order_data)
    
    order = service.get_order_by_id(new_order.id)
    assert order is not None
    assert order.id == new_order.id
    assert order.customer_name == "Alice Johnson"

def test_update_order(service):
    # Crear un pedido
    order_data = ShippingOrderCreate(
        customer_name="Bob Brown",
        product="Headphones",
        quantity=1,
        price=150.00
    )
    new_order = service.create_order(order_data)
    
    update_data = ShippingOrderUpdate(
        customer_name="Robert Brown",
        product="Wireless Headphones",
        quantity=2,
        price=200.00
    )
    updated_order = service.update_order(new_order.id, update_data)
    
    assert updated_order is not None
    assert updated_order.customer_name == "Robert Brown"
    assert updated_order.product == "Wireless Headphones"
    assert updated_order.quantity == 2
    assert updated_order.price == 200.00

def test_delete_order(service):
    # Crear un pedido
    order_data = ShippingOrderCreate(
        customer_name="Charlie Davis",
        product="Smartwatch",
        quantity=1,
        price=250.00
    )
    new_order = service.create_order(order_data)
    
    # Eliminar el pedido
    result = service.delete_order(new_order.id)
    
    assert result is True
    assert service.get_order_by_id(new_order.id) is None
