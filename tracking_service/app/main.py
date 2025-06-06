from fastapi import FastAPI
from app.api.routes import router as tracking_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Tracking Microservice",
    description="Microservice for tracking shipments (like Servientrega/FedEx)",
    version="1.0.0",
)

# Configuración de CORS
origins = [
    "http://localhost:8080",  # Flutter web local
    "http://localhost:8000",  # Otro posible puerto del frontend
    # "https://tu-front-end.com",  # Producción, descomenta si aplica
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(tracking_router, prefix="/tracking", tags=["Tracking"])
