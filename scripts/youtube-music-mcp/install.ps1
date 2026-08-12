param(
    [string]$ClientSecret = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Require-Command([string]$Name) {
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) { throw "Required command not installed or not on PATH: $Name" }
    return $cmd
}

$uv = Require-Command "uv"
$codex = Require-Command "codex"

$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptsRoot = Split-Path -Parent $SourceDir
$InstallDir = Join-Path $env:LOCALAPPDATA "OpenAI\YouTubeMusicMCP"
$VenvDir = Join-Path $InstallDir ".venv"
$PythonExe = Join-Path $VenvDir "Scripts\python.exe"
$ServerPath = Join-Path $InstallDir "server.py"
$AuthPath = Join-Path $InstallDir "auth.py"

Write-Host "[1/5] Installing isolated MCP runtime"
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
Copy-Item (Join-Path $SourceDir "server.py") $ServerPath -Force
Copy-Item (Join-Path $SourceDir "auth.py") $AuthPath -Force
Copy-Item (Join-Path $SourceDir "pyproject.toml") (Join-Path $InstallDir "pyproject.toml") -Force

& $uv.Source sync --project $InstallDir
if ($LASTEXITCODE -ne 0) { throw "uv sync failed with exit code $LASTEXITCODE" }
if (-not (Test-Path -LiteralPath $PythonExe -PathType Leaf)) {
    throw "Expected Python executable not found: $PythonExe"
}

Write-Host "[2/5] Registering youtube_music with normal interactive Codex"
$McpList = (& $codex.Source mcp list 2>&1 | Out-String)
if ($McpList -match "(?m)^\s*youtube_music\b") {
    Write-Host "youtube_music is already registered; deterministic install path is unchanged."
}
else {
    & $codex.Source mcp add youtube_music -- $PythonExe $ServerPath
    if ($LASTEXITCODE -ne 0) { throw "codex mcp add failed with exit code $LASTEXITCODE" }
}

Write-Host "[3/5] Google OAuth"
if ([string]::IsNullOrWhiteSpace($ClientSecret)) {
    Write-Host "OAuth deferred: no -ClientSecret was supplied."
    Write-Host "Authorize later with:"
    Write-Host "  & '$PythonExe' '$AuthPath' 'C:\path\to\client_secret.json'"
}
else {
    $ResolvedClientSecret = (Resolve-Path -LiteralPath $ClientSecret).Path
    & $PythonExe $AuthPath $ResolvedClientSecret
    if ($LASTEXITCODE -ne 0) { throw "OAuth bootstrap failed with exit code $LASTEXITCODE" }
}

Write-Host "[4/5] Refreshing installed ChatGPT-Codex bridge when present"
$BridgeSourceDir = Join-Path $ScriptsRoot "codex-chatgpt-bridge"
$BridgeRuntimeDir = Join-Path $env:LOCALAPPDATA "OpenAI\CodexChatGPTBridge"
$BridgeTaskName = "OpenAI Codex ChatGPT Bridge"

if ((Test-Path -LiteralPath $BridgeSourceDir -PathType Container) -and
    (Test-Path -LiteralPath $BridgeRuntimeDir -PathType Container)) {
    $TaskExists = $false
    if (Get-Command schtasks.exe -ErrorAction SilentlyContinue) {
        & schtasks.exe /Query /TN $BridgeTaskName *> $null
        $TaskExists = ($LASTEXITCODE -eq 0)
    }

    if ($TaskExists) {
        & schtasks.exe /End /TN $BridgeTaskName *> $null
        Start-Sleep -Seconds 1
    }

    foreach ($name in @("bridge-daemon.ps1", "send-task.ps1")) {
        $source = Join-Path $BridgeSourceDir $name
        if (Test-Path -LiteralPath $source -PathType Leaf) {
            Copy-Item $source (Join-Path $BridgeRuntimeDir $name) -Force
        }
    }

    if ($TaskExists) {
        & schtasks.exe /Run /TN $BridgeTaskName | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "Failed to restart scheduled task: $BridgeTaskName" }
    }
}
else {
    Write-Host "ChatGPT-Codex bridge runtime not found; bridge refresh skipped."
}

Write-Host "[5/5] Verification"
& $codex.Source mcp list | Out-Host
if ($LASTEXITCODE -ne 0) { throw "codex mcp list failed with exit code $LASTEXITCODE" }

$tokenPath = Join-Path $InstallDir "token.json"
Write-Host ""
Write-Host "Runtime: $InstallDir"
Write-Host "MCP name: youtube_music"
Write-Host "Tools: search_music, create_playlist, add_video_to_playlist, list_my_playlists, list_playlist_items"
Write-Host "OAuth token: $(if (Test-Path -LiteralPath $tokenPath -PathType Leaf) { 'configured' } else { 'NOT configured yet' })"
