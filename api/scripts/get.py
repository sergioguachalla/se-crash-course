import requests

"""
Es buena práctica tener las constantes definidas en tu .env 
y usar `os.getenv` y/o `dotenv.load_dotenv` para acceder a ellas.
"""
URL = "https://jsonplaceholder.typicode.com/posts/1"

def main():
    resp = requests.get(URL, timeout=5)
    if resp.ok:
        data = resp.json()
        print("Respuesta GET:", data)
        print("ID:", data.get("id"))
        print("Título:", data.get("title"))
        print("Contenido:", data.get("body"))
    else:
        print("Error GET:", resp.status_code, resp.text)

if __name__ == "__main__":
    main()
