from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import router as tracking_router

app = FastAPI(
    title="Tracking Microservice",
    description="Microservice for tracking shipments (like Servientrega/FedEx)",
    version="1.0.0",
)

origins = [
    "http://localhost:8080",
    "http://localhost:8000",
    # "https://tu-front-end.com",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(tracking_router, prefix="/api/events", tags=["Tracking"])
