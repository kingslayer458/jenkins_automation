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
