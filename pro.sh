#!/bin/bash

# Clean up old project if exists
rm -rf market_app

# Create directory structure
mkdir -p market_app/{auth,models,repositories,services,controllers,data}

# ===========================================
#  AUTH LAYER
# ===========================================
touch market_app/auth/__init__.py

cat > market_app/auth/basic_auth.py << 'EOF'
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials
import secrets

security = HTTPBasic()

USERS_DB = {
    "admin": "admin123",
    "seller1": "sell@pass",
    "buyer1": "buy@pass",
}


def authenticate(credentials: HTTPBasicCredentials = Depends(security)) -> str:
    password = USERS_DB.get(credentials.username)
    if password is None or not secrets.compare_digest(
        credentials.password.encode(), password.encode()
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username
EOF

# ===========================================
#  MODELS LAYER
# ===========================================
cat > market_app/models/__init__.py << 'EOF'
from .product_model import ProductInput, ProductResponse
from .buyer_model import BuyerInput, BuyerResponse
from .order_model import OrderInput, OrderMapping
EOF

cat > market_app/models/product_model.py << 'EOF'
from pydantic import BaseModel
from typing import Optional


class ProductInput(BaseModel):
    name: str
    category: str
    price: float
    stock: int


class ProductResponse(BaseModel):
    product_id: str
    name: str
    category: str
    price: float
    stock: int
    created_by: str
    created_at: str
EOF

cat > market_app/models/buyer_model.py << 'EOF'
from pydantic import BaseModel
from typing import Optional


class BuyerInput(BaseModel):
    name: str
    email: str
    phone: str
    address: str


class BuyerResponse(BaseModel):
    buyer_id: str
    name: str
    email: str
    phone: str
    address: str
    created_by: str
    created_at: str
EOF

cat > market_app/models/order_model.py << 'EOF'
from pydantic import BaseModel
from typing import Dict


class OrderInput(BaseModel):
    product_id: str
    buyer_id: str
    quantity: int


class ProductMapping(BaseModel):
    product_id: str
    name: str
    category: str
    price_per_unit: float
    stock_before: int
    stock_after: int


class BuyerMapping(BaseModel):
    buyer_id: str
    name: str
    email: str
    phone: str
    delivery_address: str


class OrderMapping(BaseModel):
    order_id: str
    quantity: int
    total_price: float
    status: str
    created_at: str
    product: ProductMapping
    buyer: BuyerMapping
EOF

# ===========================================
#  REPOSITORY LAYER (JSON FILE PERSISTENCE)
# ===========================================
cat > market_app/repositories/__init__.py << 'EOF'
from .product_repo import ProductRepository
from .buyer_repo import BuyerRepository
from .order_repo import OrderRepository
EOF

cat > market_app/repositories/product_repo.py << 'EOF'
import json
import os
from typing import Dict, Optional, List

DATA_FILE = "data/products.json"


class ProductRepository:
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

    def save(self, product_id: str, data: dict) -> dict:
        self._store[product_id] = data
        self._save()
        return data

    def find_by_id(self, product_id: str) -> Optional[dict]:
        return self._store.get(product_id)

    def find_all(self) -> List[dict]:
        return list(self._store.values())

    def update(self, product_id: str, updates: dict) -> Optional[dict]:
        product = self._store.get(product_id)
        if product:
            product.update(updates)
            self._save()
        return product


product_repo = ProductRepository()
EOF

cat > market_app/repositories/buyer_repo.py << 'EOF'
import json
import os
from typing import Dict, Optional, List

DATA_FILE = "data/buyers.json"


class BuyerRepository:
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

    def save(self, buyer_id: str, data: dict) -> dict:
        self._store[buyer_id] = data
        self._save()
        return data

    def find_by_id(self, buyer_id: str) -> Optional[dict]:
        return self._store.get(buyer_id)

    def find_all(self) -> List[dict]:
        return list(self._store.values())


buyer_repo = BuyerRepository()
EOF

cat > market_app/repositories/order_repo.py << 'EOF'
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
EOF

# ===========================================
#  SERVICE LAYER
# ===========================================
cat > market_app/services/__init__.py << 'EOF'
from .product_service import ProductService
from .buyer_service import BuyerService
from .order_service import OrderService
EOF

cat > market_app/services/product_service.py << 'EOF'
from datetime import datetime
import uuid
from fastapi import HTTPException

from models.product_model import ProductInput
from repositories.product_repo import product_repo


class ProductService:

    @staticmethod
    def create_product(data: ProductInput, username: str) -> dict:
        product_id = "PROD-" + uuid.uuid4().hex[:8].upper()
        product = {
            "product_id": product_id,
            "name": data.name,
            "category": data.category,
            "price": data.price,
            "stock": data.stock,
            "created_by": username,
            "created_at": datetime.now().isoformat(),
        }
        return product_repo.save(product_id, product)

    @staticmethod
    def get_product(product_id: str) -> dict:
        product = product_repo.find_by_id(product_id)
        if not product:
            raise HTTPException(status_code=404, detail="Product '{}' not found.".format(product_id))
        return product

    @staticmethod
    def get_all_products() -> list:
        return product_repo.find_all()

    @staticmethod
    def reduce_stock(product_id: str, quantity: int) -> None:
        current = product_repo.find_by_id(product_id)
        if current:
            product_repo.update(product_id, {
                "stock": current["stock"] - quantity
            })
EOF

cat > market_app/services/buyer_service.py << 'EOF'
from datetime import datetime
import uuid
from fastapi import HTTPException

from models.buyer_model import BuyerInput
from repositories.buyer_repo import buyer_repo


class BuyerService:

    @staticmethod
    def create_buyer(data: BuyerInput, username: str) -> dict:
        buyer_id = "BUY-" + uuid.uuid4().hex[:8].upper()
        buyer = {
            "buyer_id": buyer_id,
            "name": data.name,
            "email": data.email,
            "phone": data.phone,
            "address": data.address,
            "created_by": username,
            "created_at": datetime.now().isoformat(),
        }
        return buyer_repo.save(buyer_id, buyer)

    @staticmethod
    def get_buyer(buyer_id: str) -> dict:
        buyer = buyer_repo.find_by_id(buyer_id)
        if not buyer:
            raise HTTPException(status_code=404, detail="Buyer '{}' not found.".format(buyer_id))
        return buyer

    @staticmethod
    def get_all_buyers() -> list:
        return buyer_repo.find_all()
EOF

cat > market_app/services/order_service.py << 'EOF'
from datetime import datetime
import uuid
from fastapi import HTTPException

from models.order_model import OrderInput
from repositories.order_repo import order_repo
from services.product_service import ProductService
from services.buyer_service import BuyerService


class OrderService:

    @staticmethod
    def create_order(data: OrderInput, username: str) -> dict:
        product = ProductService.get_product(data.product_id)
        buyer = BuyerService.get_buyer(data.buyer_id)

        if product["stock"] < data.quantity:
            raise HTTPException(
                status_code=400,
                detail="Insufficient stock. Available: {}, Requested: {}".format(
                    product["stock"], data.quantity
                ),
            )

        order_id = "ORD-" + uuid.uuid4().hex[:8].upper()
        total_price = round(product["price"] * data.quantity, 2)

        order = {
            "order_id": order_id,
            "quantity": data.quantity,
            "total_price": total_price,
            "status": "CONFIRMED",
            "created_at": datetime.now().isoformat(),
            "product": {
                "product_id": product["product_id"],
                "name": product["name"],
                "category": product["category"],
                "price_per_unit": product["price"],
                "stock_before": product["stock"],
                "stock_after": product["stock"] - data.quantity,
            },
            "buyer": {
                "buyer_id": buyer["buyer_id"],
                "name": buyer["name"],
                "email": buyer["email"],
                "phone": buyer["phone"],
                "delivery_address": buyer["address"],
            },
        }

        ProductService.reduce_stock(data.product_id, data.quantity)
        return order_repo.save(order_id, order)

    @staticmethod
    def get_all_orders() -> list:
        return order_repo.find_all()
EOF

# ===========================================
#  CONTROLLER LAYER
# ===========================================
cat > market_app/controllers/__init__.py << 'EOF'
from .product_controller import router as product_router
from .buyer_controller import router as buyer_router
from .order_controller import router as order_router
EOF

cat > market_app/controllers/product_controller.py << 'EOF'
from fastapi import APIRouter, Depends

from auth.basic_auth import authenticate
from models.product_model import ProductInput, ProductResponse
from services.product_service import ProductService

router = APIRouter(prefix="/url1", tags=["URL1 - Product"])


@router.post("/product", response_model=ProductResponse, status_code=201)
def create_product(data: ProductInput, username: str = Depends(authenticate)):
    return ProductService.create_product(data, username)


@router.get("/products")
def list_products():
    products = ProductService.get_all_products()
    return {"count": len(products), "products": products}
EOF

cat > market_app/controllers/buyer_controller.py << 'EOF'
from fastapi import APIRouter, Depends

from auth.basic_auth import authenticate
from models.buyer_model import BuyerInput, BuyerResponse
from services.buyer_service import BuyerService

router = APIRouter(prefix="/url2", tags=["URL2 - Buyer"])


@router.post("/buyer", response_model=BuyerResponse, status_code=201)
def create_buyer(data: BuyerInput, username: str = Depends(authenticate)):
    return BuyerService.create_buyer(data, username)


@router.get("/buyers")
def list_buyers():
    buyers = BuyerService.get_all_buyers()
    return {"count": len(buyers), "buyers": buyers}
EOF

cat > market_app/controllers/order_controller.py << 'EOF'
from fastapi import APIRouter, Depends

from auth.basic_auth import authenticate
from models.order_model import OrderInput, OrderMapping
from services.order_service import OrderService

router = APIRouter(prefix="/url3", tags=["URL3 - Order Mapping"])


@router.post("/order", response_model=OrderMapping, status_code=201)
def create_order(data: OrderInput, username: str = Depends(authenticate)):
    return OrderService.create_order(data, username)


@router.get("/orders")
def list_orders():
    orders = OrderService.get_all_orders()
    return {"count": len(orders), "orders": orders}
EOF

# ===========================================
#  MAIN ENTRY POINT
# ===========================================
cat > market_app/main.py << 'EOF'
from fastapi import FastAPI

from controllers import product_router, buyer_router, order_router

app = FastAPI(title="Demo Market App", version="2.0.0")

app.include_router(product_router)
app.include_router(buyer_router)
app.include_router(order_router)


@app.get("/", tags=["Root"])
def root():
    return {
        "app": "Demo Market App v2 - Layered Architecture",
        "flow": {
            "step_1": "POST /url1/product  -> returns product_id",
            "step_2": "POST /url2/buyer    -> returns buyer_id",
            "step_3": "POST /url3/order    -> maps product_id + buyer_id",
        },
        "storage": "JSON files in data/ folder (persistent)",
        "docs": "/docs",
    }
EOF

# ===========================================
#  REQUIREMENTS
# ===========================================
cat > market_app/requirements.txt << 'EOF'
fastapi
uvicorn[standard]
EOF

# ===========================================
#  .GITIGNORE
# ===========================================
cat > market_app/.gitignore << 'EOF'
__pycache__/
data/*.json
*.pyc
EOF

echo ""
echo "============================================="
echo "  Project created successfully!"
echo "============================================="
echo ""
echo "  To run:"
echo "    cd market_app"
echo "    pip install -r requirements.txt"
echo "    python -m uvicorn main:app --reload"
echo ""
echo "  Credentials:"
echo "    admin   / admin123"
echo "    seller1 / sell@pass"
echo "    buyer1  / buy@pass"
echo ""
echo "  Docs: http://localhost:8000/docs"
echo "============================================="