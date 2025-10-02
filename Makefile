# Makefile (macOS) — usa los scripts bash en scripts/macos
SHELL := /bin/bash

# Rutas a scripts
CHECK_TOOLS   := ./scripts/macos/check_tools.sh
INSTALL_TOOLS := ./scripts/macos/install_tools.sh
SETUP_VENVS   := ./scripts/macos/setup_venvs.sh
DOCKER_RUN    := ./scripts/macos/docker.sh

.PHONY: help check install venvs venvs-auto compose compose-build all

## Muestra esta ayuda
help:
	@echo "Comandos disponibles:"
	@echo "  make check           - Verificar Python/Docker/Git"
	@echo "  make install         - Instalar lo que falte (Python, Git, Docker Desktop)"
	@echo "  make venvs           - Crear .venv en app_backend y streamlit (si no existen)"
	@echo "  make venvs-auto      - Igual que venvs pero instala Python si falta"
	@echo "  make compose         - docker compose up -d (solo ramas: api, sql+api)"
	@echo "  make compose-build   - igual que compose pero con --build"
	@echo "  make all             - venvs + compose"

## Verifica herramientas
check:
	$(CHECK_TOOLS)

## Instala SOLO lo que falte con Homebrew
install:
	$(INSTALL_TOOLS)

## Crea .venv en las carpetas objetivo
venvs:
	$(SETUP_VENVS)

## Crea venvs e instala Python si falta
venvs-auto:
	$(SETUP_VENVS) --auto-install

## Levanta docker compose (si rama es api o sql+api)
compose:
	$(DOCKER_RUN)

## Levanta docker compose con --build
compose-build:
	$(DOCKER_RUN) --build

## Flujo completo típico
all: venvs compose
