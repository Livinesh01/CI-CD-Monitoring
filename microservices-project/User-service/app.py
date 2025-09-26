from fastapi import FastAPI

app = FastAPI()

users = {"1": {"id": "1", "name": "Alice"}}

@app.get("/users/{user_id}")
def get_user(user_id: str):
    return users.get(user_id, {"error": "User not found"})
