from fastapi import FastAPI
from app.api.routes import router as shipping_order_router

app = FastAPI(
    title="Shipping Order Microservice",
    version="1.0.0"
)

app.include_router(shipping_order_router, prefix="", tags=["Orders"])
