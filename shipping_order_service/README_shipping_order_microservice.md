
# Shipping Order Microservice

Microservicio desarrollado con **FastAPI**, que forma parte del sistema de gestión logística (tipo Servientrega o FedEx). Este servicio se encarga de gestionar órdenes de envío de paquetes.

---

## Funcionalidades

- Crear órdenes de envío
- Consultar una orden por ID
- Cancelar órdenes
- Actualizar estado de una orden
- Rastrear una orden por tracking code
- Persistencia simulada en `orders.json`

---

## Estructura del Proyecto

shipping_order_service/
├── app/
│   ├── api/               # Rutas HTTP
│   ├── models/            # Modelo de dominio
│   ├── repository/        # Simulación de base de datos en JSON
│   ├── schemas/           # DTOs (entrada/salida)
│   ├── services/          # Lógica de negocio
│   └── main.py            # Punto de entrada de FastAPI
├── .github/workflows/ci.yml   # CI con GitHub Actions
├── requirements.txt
├── README.md
└── tests/ (opcional)

---

##Cómo ejecutar

### 1. Instalar dependencias
pip install -r requirements.txt

### 2. Iniciar servidor de desarrollo
uvicorn app.main:app --reload

### 3. Abrir documentación Swagger
http://localhost:8000/docs

---

## Archivo de datos

Las órdenes se almacenan en:
app/repository/orders.json

Este archivo actúa como base de datos simulada durante el desarrollo.

---

## Endpoints disponibles

| Método | Ruta                             | Función                          |
|--------|----------------------------------|----------------------------------|
| POST   | /orders/                         | Crear nueva orden                |
| GET    | /orders/{order_id}               | Consultar una orden              |
| DELETE | /orders/{order_id}               | Cancelar orden                   |
| PATCH  | /orders/{order_id}/status        | Actualizar estado                |
| GET    | /orders/track/{tracking_code}    | Rastrear orden por código        |

---

## Tecnología usada

- Python 3.10+
- FastAPI
- Uvicorn
- Pydantic
- JSON como base de datos temporal
- GitHub Actions para CI

---

## Estado actual

Microservicio funcional y probado  
En desarrollo de mejoras y otros microservicios

---

## CI

Este proyecto incluye un workflow para verificación automática del entorno en GitHub:

`.github/workflows/ci.yml`
