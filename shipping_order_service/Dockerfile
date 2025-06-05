FROM python:3.11-slim

WORKDIR /app

# Copia solo el código del microservicio actual
COPY app /app/app

# Copia el requirements.txt desde la raíz del proyecto (vía docker-compose context)
COPY requirements.txt /app/requirements.txt

RUN pip install --upgrade pip && \
    pip install -r /app/requirements.txt

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
