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
