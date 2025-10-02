Param(
  # Fuerza build
  [switch]$Build
)

$ErrorActionPreference = "Stop"

function Test-Cmd { param([string]$cmd) Get-Command $cmd -ErrorAction SilentlyContinue }

# Repo root y paths
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$AppPath  = Join-Path $RepoRoot "app_backend"
$AllowedBranches = @("api", "sql+api")

if (-not (Test-Path $AppPath)) { Write-Error "No existe $AppPath"; exit 1 }

# Rama actual (en la raíz del repo)
if (-not (Test-Cmd "git")) { Write-Error "Git no está disponible."; exit 1 }
$branch = git -C $RepoRoot rev-parse --abbrev-ref HEAD 2>$null
if ($LASTEXITCODE -ne 0 -or -not $branch) { Write-Error "No pude determinar la rama git."; exit 1 }
Write-Host "Rama actual: $branch" -ForegroundColor Gray

if ($AllowedBranches -notcontains $branch) {
  Write-Host " Rama no permitida. Muevete a la rama sql+api" -ForegroundColor Yellow
  exit 0
}

# Docker disponible
if (-not (Test-Cmd "docker")) {
  Write-Host "Docker no detectado. Intentando instalar..." -ForegroundColor Yellow
  $installer = Join-Path $PSScriptRoot "install_tools.ps1"
  if (Test-Path $installer) { & $installer }
  if (-not (Test-Cmd "docker")) { Write-Error "Docker sigue sin estar disponible."; exit 1 }
}

# Daemon activo
docker info 1>$null 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host "Docker Desktop no está corriendo. Ábrelo y reintenta." -ForegroundColor Yellow
  exit 1
}

# Archivo compose
$compose = @(
  Join-Path $AppPath "docker-compose.yml",
  Join-Path $AppPath "docker-compose.yaml",
  Join-Path $AppPath "compose.yml",
  Join-Path $AppPath "compose.yaml"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $compose) { Write-Error "No se encontró archivo docker compose en $AppPath."; exit 1 }
Write-Host "Usando: $(Split-Path $compose -Leaf)" -ForegroundColor Gray

Push-Location $AppPath
try {
  if ($Build) {
    docker compose up -d --build
  } else {
    docker compose up -d
  }
  if ($LASTEXITCODE -ne 0) { throw "docker compose falló" }
  Write-Host "docker compose up -d completado." -ForegroundColor Green
} finally {
  Pop-Location
}
