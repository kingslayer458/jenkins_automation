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
