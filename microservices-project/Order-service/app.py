from fastapi import FastAPI
import requests

app = FastAPI()

orders = {"5001": {"id": "5001", "user_id": "1", "product_id": "101"}}

USER_SERVICE_URL = "http://user-service:80"
PRODUCT_SERVICE_URL = "http://product-service:80"

@app.get("/orders/{order_id}")
def get_order(order_id: str):
    order = orders.get(order_id)
    if not order:
        return {"error": "Order not found"}

    # Fetch user info
    user = requests.get(f"{USER_SERVICE_URL}/users/{order['user_id']}").json()
    # Fetch product info
    product = requests.get(f"{PRODUCT_SERVICE_URL}/products/{order['product_id']}").json()

    return {"order": order, "user": user, "product": product}
