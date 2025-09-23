"""
Es un template que puedes usar para conectar una base de datos MySQL.
Ahora si por alguna razón usas otra base de datos, solo necesitas cambiar
la url. 
Por ejemplo, si usas PostgreSQL, la url cambia a:

DATABASE_URL = (
    f"postgresql+psycopg2://{POSTGRES_USER}:{POSTGRES_PASSWORD}"
    f"@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"
)

"""

import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

#Estos son los parametros de la base de datos, si ves el archivo de docker. son los mismos (o deberían ser).

MYSQL_USER = os.getenv("MYSQL_USER", "appuser")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "secretpass")
MYSQL_HOST = os.getenv("MYSQL_HOST", "127.0.0.1")  
MYSQL_PORT = int(os.getenv("MYSQL_PORT", "3305"))
MYSQL_DB = os.getenv("MYSQL_DB", "appdb")

#Simplemente es un URL que se usa para conectar a la base de datos.
#El formato es:
# "motor://usuario:contraseña@host:puerta/nombre_de_la_base_de_datos"
DATABASE_URL = (
    f"mysql+pymysql://{MYSQL_USER}:{MYSQL_PASSWORD}"
    f"@{MYSQL_HOST}:{MYSQL_PORT}/{MYSQL_DB}"
    f"?charset=utf8mb4"
)

#Ahora, create_engine es una función que se usa para crear una conexión a la base de datos.
engine = create_engine(
    DATABASE_URL)

# sessionmaker es una función que se usa para crear una sesión de la base de datos.
# Cada sesión es una transacción.

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

class Base(DeclarativeBase):
    pass

# Esto es una función que se usa para obtener una sesión de la base de datos.
# Cada vez que llamas a esta función se crea una sesión a la base de datos y puedes
# usarla para hacer operaciones CRUD (Create, Read, Update, Delete).

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
