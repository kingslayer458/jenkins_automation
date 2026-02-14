import json
import os
from typing import Dict, Optional, List

DATA_FILE = "data/orders.json"


class OrderRepository:
    def __init__(self):
        os.makedirs("data", exist_ok=True)
        self._store: Dict[str, dict] = self._load()

    def _load(self) -> Dict[str, dict]:
        if os.path.exists(DATA_FILE):
            try:
                with open(DATA_FILE, "r") as f:
                    content = f.read().strip()
                    if content:
                        return json.loads(content)
            except (json.JSONDecodeError, IOError):
                pass
        return {}

    def _save(self) -> None:
        with open(DATA_FILE, "w") as f:
            json.dump(self._store, f, indent=2)

    def save(self, order_id: str, data: dict) -> dict:
        self._store[order_id] = data
        self._save()
        return data

    def find_by_id(self, order_id: str) -> Optional[dict]:
        return self._store.get(order_id)

    def find_all(self) -> List[dict]:
        return list(self._store.values())


order_repo = OrderRepository()
