import json
from pathlib import Path
from typing import Optional, Dict
from datetime import datetime
from app.models.driver import Driver

# Ruta del archivo JSON
DB_FILE = Path("app/repository/drivers.json")


def load_drivers() -> Dict[str, dict]:
    if DB_FILE.exists():
        with DB_FILE.open("r", encoding="utf-8") as file:
            return json.load(file)
    return {}


def save_drivers(data: Dict[str, dict]):
    def default_serializer(obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        return str(obj)

    with DB_FILE.open("w", encoding="utf-8") as file:
        json.dump(data, file, indent=4, ensure_ascii=False, default=default_serializer)


def save_driver(driver: Driver):
    drivers = load_drivers()
    drivers[driver.driver_id] = driver.__dict__
    save_drivers(drivers)


def get_driver_by_id(driver_id: str) -> Optional[Driver]:
    drivers = load_drivers()
    data = drivers.get(driver_id)
    if data:
        return Driver(**data)
    return None


def get_all_drivers() -> list[Driver]:
    drivers = load_drivers()
    return [Driver(**data) for data in drivers.values()]


def update_driver(driver_id: str, updates: dict) -> bool:
    drivers = load_drivers()
    driver = drivers.get(driver_id)
    if not driver:
        return False

    driver.update(updates)
    driver["updated_at"] = datetime.utcnow().isoformat()
    save_drivers(drivers)
    return True


def delete_driver(driver_id: str) -> bool:
    drivers = load_drivers()
    if driver_id in drivers:
        drivers[driver_id]["status"] = "inactive"
        drivers[driver_id]["updated_at"] = datetime.utcnow().isoformat()
        save_drivers(drivers)
        return True
    return False
