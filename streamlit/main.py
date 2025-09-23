import streamlit as st
import pandas as pd
import requests
import logging

logging.basicConfig(
    level=logging.INFO, 
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)
API_URL = "http://127.0.0.1:8000"
st.set_page_config(page_title="Recetario", page_icon="🍳")
st.title("🍳 Recetario (CRUD)")

def api_get(path, **params):
    r = requests.get(f"{API_URL}{path}", params=params, timeout=10)
    r.raise_for_status()
    logger.info(f"GET {path} {r.status_code} {r.text}")
    return r.json()

def api_post(path, payload):
    r = requests.post(f"{API_URL}{path}", json=payload, timeout=10)
    r.raise_for_status()
    logger.info(f"POST {path} {r.status_code} {r.text}")
    return r.json()

def api_put(path, payload):
    r = requests.put(f"{API_URL}{path}", json=payload, timeout=10)
    r.raise_for_status()
    logger.info(f"PUT {path} {r.status_code} {r.text}")
    return r.json()

def api_delete(path):
    r = requests.delete(f"{API_URL}{path}", timeout=10)
    if r.status_code not in (200, 204): r.raise_for_status()
    logger.info(f"DELETE {path} {r.status_code} {r.text}")
    return True

# Sidebar: crear receta
st.sidebar.header("Nueva receta")
with st.sidebar.form("create_recipe", clear_on_submit=True):
    c_title = st.text_input("Título", max_chars=160)
    c_desc = st.text_area("Descripción", height=80)
    c_ing = st.text_area("Ingredientes (1 por línea)", height=120)
    c_steps = st.text_area("Pasos (1 por línea)", height=120)
    col_a, col_b, col_c = st.columns(3)
    with col_a: c_serv = st.number_input("Porciones", min_value=1, max_value=50, value=1)
    with col_b: c_prep = st.number_input("Min. preparación", min_value=0, max_value=10000, value=0)
    with col_c: c_veg = st.checkbox("Vegetariana", value=False)
    submitted = st.form_submit_button("➕ Crear")
    if submitted:
        try:
            api_post("/recipes", {
                "title": c_title, "description": c_desc,
                "ingredients": c_ing, "steps": c_steps,
                "servings": int(c_serv), "prep_minutes": int(c_prep),
                "vegetarian": bool(c_veg)
            })
            st.sidebar.success("Receta creada ✅")
            st.rerun()
        except Exception as e:
            st.sidebar.error(f"Error: {e}")

# Filtros y listado
st.sidebar.header("Filtro")
q = st.sidebar.text_input("Buscar (título/ingredientes)")
veg_filter = st.sidebar.selectbox("Vegetariana", options=["Todas", "Sí", "No"])
veg_param = None if veg_filter == "Todas" else (veg_filter == "Sí")

try:
    data = api_get("/recipes", q=q, vegetarian=veg_param)
    df = pd.DataFrame(data)
    if not df.empty:
        st.dataframe(df[["id","title","servings","prep_minutes","vegetarian","created_at"]],
                     use_container_width=True, hide_index=True)
    else:
        st.info("No hay recetas.")
except Exception as e:
    st.error(f"No pude cargar recetas: {e}")
    st.stop()

# Selección y edición
st.subheader("Editar / Eliminar")
if "rid" not in st.session_state: st.session_state.rid = None

left, right = st.columns([1,3])
with left:
    rid = st.number_input("ID", min_value=0, step=1, value=st.session_state.rid or 0)
    if st.button("Cargar"):
        st.session_state.rid = int(rid)
        st.rerun()

if st.session_state.rid:
    try:
        r = api_get(f"/recipes/{st.session_state.rid}")
        with st.form("edit_recipe"):
            e_title = st.text_input("Título", value=r["title"], max_chars=160)
            e_desc = st.text_area("Descripción", value=r.get("description") or "", height=80)
            e_ing = st.text_area("Ingredientes (1 por línea)", value=r["ingredients"], height=120)
            e_steps = st.text_area("Pasos (1 por línea)", value=r["steps"], height=120)
            ca, cb, cc = st.columns(3)
            with ca: e_serv = st.number_input("Porciones", min_value=1, max_value=50, value=r["servings"])
            with cb: e_prep = st.number_input("Min. preparación", min_value=0, max_value=10000, value=r["prep_minutes"])
            with cc: e_veg = st.checkbox("Vegetariana", value=r["vegetarian"])
            save = st.form_submit_button("💾 Guardar")
            del_ = st.form_submit_button("🗑️ Eliminar")
            if save:
                try:
                    api_put(f"/recipes/{r['id']}", {
                        "title": e_title, "description": e_desc,
                        "ingredients": e_ing, "steps": e_steps,
                        "servings": int(e_serv), "prep_minutes": int(e_prep),
                        "vegetarian": bool(e_veg)
                    })
                    st.success("Actualizada"); st.rerun()
                except Exception as e:
                    st.error(f"Error: {e}")
            if del_:
                try:
                    api_delete(f"/recipes/{r['id']}"); st.success("Eliminadísima")
                    st.session_state.rid = None; st.rerun()
                except Exception as e:
                    st.error(f"Error: {e}")
    except Exception as e:
        st.warning(f"No pude cargar la receta {st.session_state.rid}: {e}")
