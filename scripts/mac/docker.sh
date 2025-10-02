#!/usr/bin/env bash
# docker.sh — macOS
# Corre `docker compose up -d` en ./app_backend SOLO si la rama es `api` o `sql+api`.
# Uso:
#   ./scripts/macos/docker.sh           # up -d
#   ./scripts/macos/docker.sh --build   # up -d --build

set -euo pipefail

# --- flags ---
BUILD=0
if [[ "${1:-}" == "--build" || "${1:-}" == "-b" ]]; then
  BUILD=1
fi

# --- helpers ---
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# Repo root y rutas (asumiendo que este script está en scripts/macos/)
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
APP_PATH="$REPO_ROOT/app_backend"
ALLOWED_BRANCHES=("api" "sql+api")

# --- checks básicos ---
if [[ ! -d "$APP_PATH" ]]; then
  echo "No existe $APP_PATH" >&2
  exit 1
fi

if ! has_cmd git; then
  echo "Git no está disponible." >&2
  exit 1
fi

branch="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
if [[ -z "$branch" ]]; then
  echo "No pude determinar la rama git." >&2
  exit 1
fi
echo "Rama actual: $branch"

allowed=0
for b in "${ALLOWED_BRANCHES[@]}"; do
  [[ "$branch" == "$b" ]] && allowed=1 && break
done

if [[ $allowed -ne 1 ]]; then
  echo "Rama no permitida. Muévete a la rama 'sql+api'."
  exit 0
fi

# --- Docker instalado ---
if ! has_cmd docker; then
  echo "Docker no detectado."
  if has_cmd brew; then
    echo "Intentando instalar Docker Desktop con Homebrew..."
    # requiere interacción de usuario al primer arranque
    brew install --cask docker || {
      echo "No se pudo instalar Docker Desktop automáticamente." >&2
      exit 1
    }
  else
    echo "Instala Docker Desktop primero: https://www.docker.com/products/docker-desktop/" >&2
    exit 1
  fi
fi

# --- Daemon activo ---
if ! docker info >/dev/null 2>&1; then
  echo "Docker Desktop no está corriendo. Intentando abrirlo..."
  if has_cmd open; then
    open -a "Docker" || true
    # espera breve a que levante
    for i in {1..20}; do
      sleep 3
      if docker info >/dev/null 2>&1; then
        break
      fi
      [[ $i -eq 20 ]] && { echo "Docker aún no responde. Ábrelo y reintenta."; exit 1; }
    done
  else
    echo "Ábrelo manualmente y reintenta." >&2
    exit 1
  fi
fi

# --- Archivo compose ---
compose_file=""
for f in "docker-compose.yml" "docker-compose.yaml" "compose.yml" "compose.yaml"; do
  if [[ -f "$APP_PATH/$f" ]]; then
    compose_file="$f"
    break
  fi
done

if [[ -z "$compose_file" ]]; then
  echo "No se encontró archivo docker compose en $APP_PATH." >&2
  exit 1
fi
echo "Usando: $compose_file"

# --- Ejecutar compose ---
pushd "$APP_PATH" >/dev/null
set +e
if [[ $BUILD -eq 1 ]]; then
  docker compose up -d --build
else
  docker compose up -d
fi
code=$?
set -e
popd >/dev/null

if [[ $code -ne 0 ]]; then
  echo "docker compose falló" >&2
  exit $code
fi

echo "docker compose up -d completado."
