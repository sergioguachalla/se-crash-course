from sqlalchemy import String, Integer, Text, Boolean, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column
from .database import Base


class Recipe(Base):
    __tablename__ = "recipes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String(160), index=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    ingredients: Mapped[str] = mapped_column(Text)  # 1 por línea o CSV
    steps: Mapped[str] = mapped_column(Text)        # 1 por línea
    servings: Mapped[int] = mapped_column(Integer, default=1)
    prep_minutes: Mapped[int] = mapped_column(Integer, default=0)
    vegetarian: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[str] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[str] = mapped_column(DateTime(timezone=True), default=func.now(), onupdate=func.now())
