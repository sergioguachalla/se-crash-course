"""
Este archivo es el punto de entrada de la API para la gestión de recetas.
Acá están los endpoints que te mencionaba antes.
Son operaciones CRUD (Create, Read, Update, Delete) para la gestión de recetas.
"""

from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from .database import Base, engine, get_db
from . import models, schemas
import logging
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Recetas (CRUD)")
logger = logging.getLogger(__name__)

"""
Este endpoint sirve para obtener (GET) todas las recetas.
Puedes filtrar por título o ingredientes, y por vegetariano.
Digamos que quieres obtener todas las recetas que contengan la palabra "pasta" en el título o en los ingredientes, y que sean vegetarianas.
Entonces, la URL sería: /recipes?q=pasta&vegetarian=true
Digamos que quieres obtener todas las recetas vegetarianas.
Entonces, la URL sería: /recipes?vegetarian=true
"""
@app.get("/recipes", response_model=List[schemas.RecipeOut])
def list_recipes(q: Optional[str] = None, vegetarian: Optional[bool] = None, db: Session = Depends(get_db)):
    logger.info(f"Recieving request for recipes with q={q} and vegetarian={vegetarian}")
    query = db.query(models.Recipe)
    if q:
        like = f"%{q}%"
        query = query.filter((models.Recipe.title.ilike(like)) | (models.Recipe.ingredients.ilike(like)))
    if vegetarian is not None:
        query = query.filter(models.Recipe.vegetarian == vegetarian)
    return query.order_by(models.Recipe.id.desc()).all()


"""
Este endpoint sirve para obtener (GET) una receta por su ID.
Si la receta no existe, devuelve un error 404.
"""
@app.get("/recipes/{recipe_id}", response_model=schemas.RecipeOut)
def get_recipe(recipe_id: int, db: Session = Depends(get_db)):
    logger.info(f"Recieving request for recipe with id={recipe_id}")
    r = db.get(models.Recipe, recipe_id)
    if not r:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return r


"""
Este endpoint sirve para crear (POST) una nueva receta.
Recibe los datos de la receta en el cuerpo de la solicitud (payload) y los guarda en la base de datos.
"""
@app.post("/recipes", response_model=schemas.RecipeOut, status_code=status.HTTP_201_CREATED)
def create_recipe(payload: schemas.RecipeCreate, db: Session = Depends(get_db)):
    logger.info(f"Recieving request to create recipe with payload={payload.model_dump()}")
    r = models.Recipe(**payload.model_dump())
    db.add(r)
    db.commit()
    db.refresh(r)
    return r

"""
Este endpoint sirve para actualizar (PUT) una receta existente.
Recibe los datos de la receta en el cuerpo de la solicitud (payload) y actualiza la receta en la base de datos.
Si la receta no existe, devuelve un error 404.
"""
@app.put("/recipes/{recipe_id}", response_model=schemas.RecipeOut)
def update_recipe(recipe_id: int, payload: schemas.RecipeUpdate, db: Session = Depends(get_db)):
    logger.info(f"Recieving request to update recipe with id={recipe_id} and payload={payload.model_dump()}")
    r = db.get(models.Recipe, recipe_id)
    if not r:
        raise HTTPException(status_code=404, detail="Recipe not found")
    for k, v in payload.model_dump(exclude_unset=True).items():
        setattr(r, k, v)
    db.add(r)
    db.commit()
    db.refresh(r)
    return r



"""
Este endpoint sirve para eliminar (DELETE) una receta existente.
Recibe el ID de la receta en la URL y la elimina de la base de datos.
Si la receta no existe, devuelve un error 404.
"""
@app.delete("/recipes/{recipe_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_recipe(recipe_id: int, db: Session = Depends(get_db)):
    logger.info(f"Recieving request to delete recipe with id={recipe_id}")
    r = db.get(models.Recipe, recipe_id)
    if not r:
        raise HTTPException(status_code=404, detail="Recipe not found")
    db.delete(r)
    db.commit()
    return None
