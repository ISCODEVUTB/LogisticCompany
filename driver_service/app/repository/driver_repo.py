import json
from pathlib import Path
from typing import Optional, Dict
from datetime import datetime, timezone
from app.models.driver import Driver

# Ruta del archivo JSON
DB_FILE = Path("driver_service/app/repository/drivers.json")

# Define a set of allowed keys for Driver model initialization
ALLOWED_DRIVER_KEYS = {'driver_id', 'name', 'license_id', 'phone', 'status', 'created_at', 'updated_at'}


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

    DB_FILE.parent.mkdir(parents=True, exist_ok=True)
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
        # Filter keys to prevent TypeError during Driver instantiation
        filtered_data = {key: data[key] for key in data if key in ALLOWED_DRIVER_KEYS}
        
        # Convert string dates to datetime objects
        if 'created_at' in filtered_data and isinstance(filtered_data['created_at'], str):
            try:
                filtered_data['created_at'] = datetime.fromisoformat(filtered_data['created_at'])
            except ValueError:
                # Handle or log error if date format is unexpectedly wrong
                pass 
        if 'updated_at' in filtered_data and isinstance(filtered_data['updated_at'], str):
            try:
                filtered_data['updated_at'] = datetime.fromisoformat(filtered_data['updated_at'])
            except ValueError:
                # Handle or log error
                pass
        
        return Driver(**filtered_data)
    return None


def get_all_drivers() -> list[Driver]:
    drivers_data = load_drivers()
    result = []
    for data_value in drivers_data.values():
        # Filter keys
        filtered_data = {key: data_value[key] for key in data_value if key in ALLOWED_DRIVER_KEYS}
        
        # Convert string dates to datetime objects
        if 'created_at' in filtered_data and isinstance(filtered_data['created_at'], str):
            try:
                filtered_data['created_at'] = datetime.fromisoformat(filtered_data['created_at'])
            except ValueError:
                # Handle or log error
                pass 
        if 'updated_at' in filtered_data and isinstance(filtered_data['updated_at'], str):
            try:
                filtered_data['updated_at'] = datetime.fromisoformat(filtered_data['updated_at'])
            except ValueError:
                # Handle or log error
                pass
        
        result.append(Driver(**filtered_data))
    return result


def update_driver(driver_id: str, updates: dict) -> bool:
    drivers = load_drivers()
    driver = drivers.get(driver_id)
    if not driver:
        return False

    driver.update(updates)
    driver["updated_at"] = datetime.now(timezone.utc).isoformat()
    save_drivers(drivers)
    return True


def delete_driver(driver_id: str) -> bool:
    drivers = load_drivers()
    if driver_id in drivers:
        drivers[driver_id]["status"] = "inactive"
        drivers[driver_id]["updated_at"] = datetime.now(timezone.utc).isoformat()
        save_drivers(drivers)
        return True
    return False
