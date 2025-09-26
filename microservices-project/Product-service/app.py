from fastapi import FastAPI

app = FastAPI()

products = {"101": {"id": "101", "name": "Laptop"}}

@app.get("/products/{product_id}")
def get_product(product_id: str):
    return products.get(product_id, {"error": "Product not found"})
