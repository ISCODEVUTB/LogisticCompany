from fastapi import FastAPI
from app.api.routes import router as shipping_order_router

app = FastAPI(
    title="Shipping Order Microservice",
    description="Microservice for managing shipping orders (like Servientrega/FedEx).",
    version="1.0.0"
)

# Registrar las rutas bajo el prefijo "/orders"
app.include_router(shipping_order_router, prefix="/orders", tags=["Shipping Orders"])
