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
