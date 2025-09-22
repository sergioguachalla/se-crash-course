import requests

URL = "https://jsonplaceholder.typicode.com/posts"
payload = {
    "title": "tarta de manzana",
    "body": "receta v1",
    "userId": 1
}

def main():
    resp = requests.post(URL, json=payload, timeout=5)
    if resp.ok:
        created = resp.json()
        print("Respuesta POST:", created)
        print("Creado con ID:", created.get("id"))
    else:
        print("Error POST:", resp.status_code, resp.text)

if __name__ == "__main__":
    main()
