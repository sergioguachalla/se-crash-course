from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class RecipeBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=160)
    description: Optional[str] = None
    ingredients: str = Field(..., description="Lista separada por líneas")
    steps: str = Field(..., description="Lista separada por líneas")
    servings: int = Field(1, ge=1, le=50)
    prep_minutes: int = Field(0, ge=0, le=10000)
    vegetarian: bool = False

class RecipeCreate(RecipeBase):
    pass

class RecipeUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=160)
    description: Optional[str] = None
    ingredients: Optional[str] = None
    steps: Optional[str] = None
    servings: Optional[int] = Field(None, ge=1, le=50)
    prep_minutes: Optional[int] = Field(None, ge=0, le=10000)
    vegetarian: Optional[bool] = None

class RecipeOut(RecipeBase):
    id: int
    created_at: datetime | None = None
    updated_at: datetime | None = None

    class Config:
        from_attributes = True
