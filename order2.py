import json
import os
import requests
from requests.auth import HTTPBasicAuth

username = "admin"
password = "admin123"

# url1 = "http://127.0.0.1:8000/url1/product"
# url2 = "http://127.0.0.1:8000/url2/buyer"
# url3 = "http://127.0.0.1:8000/url3/order"
url1 = "http://host.docker.internal:8000/url1/product"
url2 = "http://host.docker.internal:8000/url2/buyer"
url3 = "http://host.docker.internal:8000/url3/order"

# 🔹 Read JSON input from Jenkins parameters
payload = {
    "name": os.environ["PRODUCT_NAME"],
    "category": os.environ["CATEGORY"],
    "price": int(os.environ["PRICE"]),
    "stock": int(os.environ["STOCK"])
}

payload2 = {
    "name": os.environ["BUYER_NAME"],
    "email": os.environ["EMAIL"],
    "phone": os.environ["PHONE"],
    "address": os.environ["ADDRESS"]
}

# ---------------- First POST ----------------
re = requests.post(
    url1,
    auth=HTTPBasicAuth(username, password),
    json=payload
)

stored1 = re.json()
product_id = stored1["product_id"]

print("\n1st payload output")
print(json.dumps(stored1, indent=4))


# ---------------- Second POST ----------------
re2 = requests.post(
    url2,
    auth=HTTPBasicAuth(username, password),
    json=payload2
)

stored2 = re2.json()
buyer_id = stored2["buyer_id"]

print("\n2nd payload output")
print(json.dumps(stored2, indent=4))


# ---------------- Third POST ----------------
payload3 = {
    "product_id": product_id,
    "buyer_id": buyer_id,
    "quantity": 1
}

re3 = requests.post(
    url3,
    auth=HTTPBasicAuth(username, password),
    json=payload3
)

stored3 = re3.json()

print("\n3rd payload output")
print(json.dumps(stored3, indent=4))
