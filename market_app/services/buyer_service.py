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
