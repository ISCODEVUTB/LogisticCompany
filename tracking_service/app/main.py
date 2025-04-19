from fastapi import FastAPI
from app.api.routes import tracking_router

app = FastAPI(
    title="Tracking Microservice",
    description="Microservice for tracking shipments (like Servientrega/FedEx)",
    version="1.0.0",
)

# Register the tracking router with prefix
app.include_router(tracking_router.router, prefix="/tracking", tags=["Tracking"])
