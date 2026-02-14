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
