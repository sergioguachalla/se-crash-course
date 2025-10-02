Param(
  [string[]]$Dirs = @(
    "./se-crash-course/app_backend",
    "./se-crash-course/streamlit"
  ),
  [switch]$AutoInstall
)

$ErrorActionPreference = "Stop"

function Test-Cmd { param([string]$cmd) Get-Command $cmd -ErrorAction SilentlyContinue }

if (-not (Test-Cmd "python")) {
  if ($AutoInstall) {
    Write-Host "Python no detectado. Intentando instalar..." -ForegroundColor Yellow
    & "$PSScriptRoot\install_tools.ps1"
  } else {
    Write-Error "Python no está instalado. Instálalo o corre con -AutoInstall."
    exit 1
  }
}

foreach ($d in $Dirs) {
  $path = Resolve-Path $d -ErrorAction SilentlyContinue
  if (-not $path) {
    Write-Host "⚠ No existe: $d — saltando." -ForegroundColor Yellow
    continue
  }

  $venv = Join-Path $path ".venv"
  if (Test-Path $venv) {
    Write-Host "✓ venv ya existe en $d" -ForegroundColor Green
    continue
  }

  Write-Host "Creando venv en $d..." -ForegroundColor Cyan
  Push-Location $path
  try {
    & python -m venv .venv
    if ($LASTEXITCODE -ne 0) { throw "falló python -m venv" }

    # (Opcional) actualizar pip básico, sin instalar deps del proyecto
    $py = Join-Path ".venv" "Scripts\python.exe"
    if (Test-Path $py) {
      & $py -m pip install --upgrade pip setuptools wheel | Out-Null
    }
    Write-Host "✔ venv creado en $d" -ForegroundColor Green
  } finally {
    Pop-Location
  }
}

Write-Host "Listo." -ForegroundColor Green
