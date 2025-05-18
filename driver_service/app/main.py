from fastapi import FastAPI
from app.api.routes import router as driver_router

app = FastAPI(
    title="Driver Microservice",
    description="Microservice for managing delivery drivers",
    version="1.0.0"
)

# Registrar las rutas bajo el prefijo /drivers
app.include_router(driver_router, prefix="/drivers", tags=["Drivers"])
