from fastapi import FastAPI
from app.api.routes import router as tracking_router

app = FastAPI(
    title="Tracking Microservice",
    description="Microservice for tracking shipments (like Servientrega/FedEx)",
    version="1.0.0",
)

app.include_router(tracking_router, prefix="/tracking", tags=["Tracking"])
