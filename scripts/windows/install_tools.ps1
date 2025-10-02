#Requires -Version 5.1
Param()

function Ensure-Admin {
  $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
  if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevando a administrador..." -ForegroundColor Yellow
    $psi = New-Object System.Diagnostics.ProcessStartInfo "powershell"
    $psi.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = "runas"
    [Diagnostics.Process]::Start($psi) | Out-Null
    exit
  }
}

function Winget-Ensure {
  param([string]$Id, [string]$NameShown)
  Write-Host "`n=== $NameShown ===" -ForegroundColor Cyan
  $exists = winget list --id $Id -e --source winget 2>$null
  if ($LASTEXITCODE -eq 0 -and $exists) {
    Write-Host "Actualizando $NameShown si aplica..."
    winget upgrade --id $Id -e --source winget --accept-source-agreements --accept-package-agreements
  } else {
    Write-Host "Instalando $NameShown..."
    winget install --id $Id -e --source winget --accept-source-agreements --accept-package-agreements
  }
}

Ensure-Admin

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "No se encontró winget. En Windows 10/11 moderno viene preinstalado. Instálalo y reintenta."
  exit 1
}

Winget-Ensure -Id "Python.Python.3.12" -NameShown "Python"
Winget-Ensure -Id "Git.Git"           -NameShown "Git"
Winget-Ensure -Id "Docker.DockerDesktop" -NameShown "Docker Desktop"

Write-Host "`nListo. Puede que Docker Desktop requiera reinicio o primer arranque manual." -ForegroundColor Green
