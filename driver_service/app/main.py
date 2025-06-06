from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import router as driver_router

app = FastAPI(
    title="Driver Microservice",
    description="Microservice for managing delivery drivers",
    version="1.0.0"
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

# Registrar las rutas bajo el prefijo /drivers
app.include_router(driver_router, prefix="/api/drivers", tags=["Drivers"])