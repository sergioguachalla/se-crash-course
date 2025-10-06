# SQL a ORM

## Modelos (nuevamente)
Básicamente representas una tabla. 
Por ejemplo:
- En SQL crearías una tabla `users`.
- En SQLAlchemy creas una clase `User`.

tendrías este modelo:
```python
class User(Base):
    __tablename__ = 'users'  # Nombre de la tabla en la base de datos

    # Definición de columnas (atributos)
    id = Column(Integer, primary_key=True)  # clave primaria
    name = Column(String)                   # texto
    age = Column(Integer)                   # número entero
    country = Column(String)                # texto

    # Relación 1 a muchos: un usuario puede tener varios posts
    posts = relationship("Post", back_populates="user")

    def __repr__(self):
        return f"<User(name='{self.name}', country='{self.country}')>"
```	
y este modelo de tu tabla post
```python
class Post(Base):
    __tablename__ = 'posts'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'))  # clave foránea a User
    title = Column(String)
    views = Column(Integer)
    category = Column(String)

    # Relación inversa: cada post pertenece a un usuario
    user = relationship("User", back_populates="posts")

    def __repr__(self):
        return f"<Post(title='{self.title}', views={self.views})>"
```

## Consultas
Entonces para hacer un "traductor" de sql a orm, puedes usar los métodos de la clase `Session` que te proporciona SQLAlchemy. Por ejemplo:
### Select (SQL y ORM)
En SQL:
```sql
SELECT * FROM users;
```
En ORM:
```python
session.query(User).all()
```
### Select con condiciones
En SQL:
```sql
SELECT * FROM users WHERE country = 'Argentina';
```
En ORM:
```python
session.query(User).filter(User.country == 'Argentina').all()
```
### Joins
En SQL:
```sql
SELECT users.name, posts.title FROM users JOIN posts ON users.id = posts.user_id;
```
En ORM:
```python
session.query(User.name, Post.title).join(Post).all()
```
### Group by
En SQL:
```sql
SELECT country, COUNT(*) FROM users GROUP BY country;
```
En ORM:
```python
session.query(User.country, func.count(User.id)).group_by(User.country).all()
```

### Order by
En SQL:
```sql
SELECT * FROM users ORDER BY age DESC;
```
En ORM:
```python
session.query(User).order_by(User.age.desc()).all()
```

### Subqueries
En SQL:
```sql
SELECT * FROM users WHERE id IN (SELECT user_id FROM posts WHERE category = 'tech');
```
En ORM:
```python
session.query(User).filter(User.id.in_(session.query(Post.user_id).filter(Post.category == 'tech'))).all()
```

### Filtros (and, or, not)
#### And
En SQL:
```sql
SELECT * FROM users WHERE country = 'Argentina' AND age > 30;
```
En ORM:
```python
session.query(User).filter(User.country == 'Argentina', User.age > 30).all()
```

#### Or
En SQL:
```sql
SELECT * FROM users WHERE country = 'Argentina' OR country = 'Brasil';
```
En ORM:
```python
session.query(User).filter(User.country == 'Argentina', User.country == 'Brasil').all()
```
#### Not
En SQL:
```sql
SELECT * FROM users WHERE country != 'Argentina';
```
En ORM:
```python
session.query(User).filter(User.country != 'Argentina').all()
```




