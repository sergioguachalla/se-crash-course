# Consumir APIs 

## Qué es un API
Es como una puerta de entrada/portero que permite a diferentes servicios comunicarse entre sí.
Normalmente, una API perimite a un servicio acceder a los datos o funcionalidades de otro servicio.


## Conceptos mínimos 
- **Endpoint (URL):** dirección a la que haces la request, es como un recurso
  Ej.: `https://api_de_la_empresa.com/recetas`
- **Métodos HTTP:**  
  - `GET`: leer datos  
  - `POST`: crear datos
  - `PUT`: actualizar datos
  - `DELETE`: eliminar datos
- **Query params:** filtros en la URL.  
  Ej.: `https://api_de_la_empresa.com/recetas?country=Bolivia`
- **Headers:** metadatos. No te preocupes mucho por esto, solo asegurate de usar `Content-Type: application/json`.
- **Códigos de estado:**  
  - `200` OK  
  - `404` No encontrado  
  - `500` Error del servidor
  - Acá están más códigos de estado: https://developer.mozilla.org/es/docs/Web/HTTP/Status

---

## JSON

Es un formato de texto para intercambiar datos entre sistemas.

Estructura básica:
- Usa llaves `{}` para objetos
- Usa corchetes `[]` para arrays
- Los datos son pares de `"clave": valor`
- Los valores pueden ser:
  - Strings: `"hola"`
  - Números: `42`
  - Booleanos: `true/false`
  - null
  - Arrays: `[1,2,3]`
  - Otros objetos: `{"nombre": "Juan"}`

Ejemplo:
Digamos que haces un `GET` a `https://api_de_la_empresa.com/recetas` y obtienes la siguiente respuesta:
```json
{
  "id": 1,
  "nombre": "Receta 1",
  "ingredientes": ["azucar", "harina", "huevo"],
  "preparacion": "Mezclar todos los ingredientes y cocinar a fuego alto",
  "categoria": "comida"
}
```
Ya recibiendo esta respuesta, puedes acceder a los datos de la receta usando python:
```python
import json

response = requests.get('https://api_de_la_empresa.com/recetas')
data = json.loads(response.text)

print(data['nombre'])  # Imprime: Receta 1
```
## Ejemplos
- Get => **Acá**
- Post => **Acá**