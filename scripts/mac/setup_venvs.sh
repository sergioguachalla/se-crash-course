#!/usr/bin/env bash
# setup_venvs.sh — macOS
# Crea .venv en se-crash-course/app_backend y se-crash-course/streamlit.
# Uso:
#   ./scripts/macos/setup_venvs.sh
#   ./scripts/macos/setup_venvs.sh --auto-install   # instala Python si falta (vía install_tools.sh)

set -euo pipefail

AUTO_INSTALL=0
if [[ "${1:-}" == "--auto-install" ]]; then
  AUTO_INSTALL=1
fi

msg() { echo -e "$*"; }
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# Localiza rutas basadas en la ubicación del script
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Carpetas objetivo
DIRS=(
  "$REPO_ROOT/se-crash-course/app_backend"
  "$REPO_ROOT/se-crash-course/streamlit"
)

# Resolver Python (preferimos python3)
PY_BIN=""
if has_cmd python3; then
  PY_BIN="python3"
elif has_cmd python; then
  PY_BIN="python"
fi

if [[ -z "$PY_BIN" ]]; then
  if [[ $AUTO_INSTALL -eq 1 ]]; then
    msg "Python no detectado. Intentando instalar..."
    if [[ -x "$SCRIPT_DIR/install_tools.sh" ]]; then
      "$SCRIPT_DIR/install_tools.sh" --no-open
    else
      msg "No encuentro $SCRIPT_DIR/install_tools.sh. Instala Python con Homebrew (brew install python) y reintenta."
      exit 1
    fi
    # Reintenta detección
    if has_cmd python3; then
      PY_BIN="python3"
    elif has_cmd python; then
      PY_BIN="python"
    fi
  fi
fi

if [[ -z "$PY_BIN" ]]; then
  msg "Python no está instalado. Instálalo o corre con --auto-install."
  exit 1
fi

for d in "${DIRS[@]}"; do
  if [[ ! -d "$d" ]]; then
    msg " No existe: $d — saltando."
    continue
  fi

  VENV_PATH="$d/.venv"
  if [[ -d "$VENV_PATH" ]]; then
    msg " venv ya existe en $d"
    continue
  fi

  msg "Creando venv en $d..."
  (
    cd "$d"
    "$PY_BIN" -m venv .venv
    if [[ -x ".venv/bin/python" ]]; then
      ".venv/bin/python" -m pip install --upgrade pip setuptools wheel >/dev/null
    fi
  )
  msg " venv creado en $d"
done

msg "Listo "
