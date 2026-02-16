import json
import requests
from requests.auth import HTTPBasicAuth

username="admin"
password="admin123"

url1 = "http://127.0.0.1:8000/url1/product"
url2 = "http://127.0.0.1:8000/url2/buyer"
url3 = "http://127.0.0.1:8000/url3/order"

payload = {
  "name": "acer",
  "category": "laptop",
  "price": 30,
  "stock": 1
}

payload2={
  "name": "manoj",
  "email": "mk458557",
  "phone": "9000000003",
  "address": "vip colony"
}

re= requests.post(url1,
                auth=HTTPBasicAuth(username,password),
                json=payload)

re2= requests.post(url2,
                auth=HTTPBasicAuth(username,password),
                json=payload2)

#storing 2 payload
stored1= re.json()
#extracting inputs
product_id=stored1["product_id"]

stored2= re2.json()
#extracting inputs
buyer_id=stored2["buyer_id"]

# print("\n 1st payload output")
# print(json.dumps(stored1,indent=4))


# print("\n 2st payload output")
# print(json.dumps(stored2,indent=4))

#mapping

payload3 = {
  "product_id": product_id,
  "buyer_id": buyer_id,
  "quantity": 1
}

re3= requests.post(url3,
                auth=HTTPBasicAuth(username,password),
                json=payload3)

stored3= re3.json()

print("\n 3st payload output")
print(json.dumps(stored3,indent=4))