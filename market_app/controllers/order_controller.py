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
