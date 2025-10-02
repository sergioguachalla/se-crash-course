Param(
  [switch]$Quiet
)

function Test-Cmd { param([string]$cmd) Get-Command $cmd -ErrorAction SilentlyContinue }

$tools = @(
  @{ Name="Python"; Cmd="python"; VersionArgs="--version" },
  @{ Name="Docker"; Cmd="docker"; VersionArgs="--version" },
  @{ Name="Git";    Cmd="git";    VersionArgs="--version" }
)

$missing = @()

foreach ($t in $tools) {
  $cmd = Test-Cmd $t.Cmd
  if (-not $cmd) {
    if (-not $Quiet) { Write-Host "✗ $($t.Name) no está instalado" -ForegroundColor Red }
    $missing += $t.Name
    continue
  }
  try {
    $v = & $t.Cmd $t.VersionArgs 2>$null
    if (-not $Quiet) { Write-Host "✓ $($t.Name): $v" -ForegroundColor Green }
  } catch {
    if (-not $Quiet) { Write-Host "✓ $($t.Name) detectado" -ForegroundColor Green }
  }
}

if ($missing.Count -gt 0) {
  if (-not $Quiet) { Write-Host "`nFaltan: $($missing -join ', ')" -ForegroundColor Yellow }
  exit 1
}

exit 0
