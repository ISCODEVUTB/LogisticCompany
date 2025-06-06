from fastapi import FastAPI
from app.api.routes import router as route_router

app = FastAPI(title="Routing Microservice")
app.include_router(route_router)
