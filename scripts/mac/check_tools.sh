#!/usr/bin/env bash
# check_tools.sh — macOS
# Verifica Python, Docker y Git. Imprime versiones y sale con 0 si todo está OK.
# Uso: ./check_tools.sh [-q|--quiet]

set -euo pipefail

QUIET=0
if [[ "${1:-}" == "-q" || "${1:-}" == "--quiet" ]]; then
  QUIET=1
fi

log() { [[ $QUIET -eq 1 ]] || echo -e "$*"; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

missing=()

# --- Python ---
PY_CMD=""
if has_cmd python3; then
  PY_CMD="python3"
elif has_cmd python; then
  # algunas Macs antiguas aún tienen 'python' apuntando a 2.x o 3.x
  PY_CMD="python"
fi

if [[ -z "$PY_CMD" ]]; then
  log "Python no está instalado"
  missing+=("Python")
else
  # intenta obtener versión
  if ver="$($PY_CMD --version 2>&1)"; then
    log "Python: $ver"
  else
    log "Python detectado"
  fi
fi

# --- Docker ---
if ! has_cmd docker; then
  log "Docker no está instalado"
  missing+=("Docker")
else
  if ver="$(docker --version 2>&1)"; then
    log "Docker: $ver"
  else
    log "Docker detectado"
  fi
fi

# --- Git ---
if ! has_cmd git; then
  log "Git no está instalado"
  missing+=("Git")
else
  if ver="$(git --version 2>&1)"; then
    log " Git: $ver"
  else
    log "Git detectado"
  fi
fi

if [[ ${#missing[@]} -gt 0 ]]; then
  log ""
  log "Faltan: ${missing[*]}"
  exit 1
fi

exit 0
