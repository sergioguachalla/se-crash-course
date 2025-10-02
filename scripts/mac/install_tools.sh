

set -euo pipefail

NO_OPEN=0
if [[ "${1:-}" == "--no-open" ]]; then
  NO_OPEN=1
fi

has_cmd() { command -v "$1" >/dev/null 2>&1; }

ensure_brew() {
  if has_cmd brew; then
    echo "Homebrew encontrado"
  else
    echo "Homebrew no encontrado. Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "${HOME}/.bash_profile"
    fi
  fi
}

brew_install_if_missing() {
  local formula="$1"
  if brew list --formula --versions "$formula" >/dev/null 2>&1; then
    echo "✓ $formula ya está instalado"
  else
    echo "→ Instalando $formula..."
    brew install "$formula"
  fi
}

brew_cask_install_if_missing() {
  local cask="$1"
  if brew list --cask --versions "$cask" >/dev/null 2>&1; then
    echo "✓ $cask ya está instalado"
  else
    echo "→ Instalando $cask..."
    brew install --cask "$cask"
  fi
}

echo "== Verificando Homebrew =="
ensure_brew


echo ""
echo "== Python =="
# Acepta python3 o python
if has_cmd python3 || has_cmd python; then
  ver="$( (python3 --version 2>/dev/null || python --version 2>/dev/null) )"
  echo "Python presente: ${ver}"
else
  brew_install_if_missing python   # instala la versión estable (crea 'python3')
fi

echo ""
echo "== Git =="
if has_cmd git; then
  echo "Git presente: $(git --version)"
else
  brew_install_if_missing git
fi

echo ""
echo "== Docker Desktop =="
if has_cmd docker; then
  echo " Docker CLI presente: $(docker --version 2>/dev/null || echo 'detectado')"
else
  brew_cask_install_if_missing docker
  if [[ $NO_OPEN -eq 0 ]]; then
    echo "→ Abriendo Docker Desktop por primera vez…"
    open -a "Docker" || true
    echo "Cuando el icono de Docker deje de parpadear, el daemon estará listo."
  else
    echo "Instalado. Abre Docker Desktop manualmente cuando quieras."
  fi
fi

echo ""
echo "Listo "
