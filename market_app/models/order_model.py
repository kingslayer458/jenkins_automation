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
