from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import router as shipping_order_router

app = FastAPI(
    title="Shipping Order Microservice",
    version="1.0.0"
)

# Configuración de CORS
origins = [
    "http://localhost:8080",
    "http://localhost:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(shipping_order_router, prefix="/api", tags=["Orders"])