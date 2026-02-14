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
