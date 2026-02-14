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
