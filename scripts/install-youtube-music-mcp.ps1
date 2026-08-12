param(
    [string]$ClientSecret = '',
    [string]$SourceRepo = 'KAFKA2306/KAFKA2306',
    [string]$SourceRef = '648565e3c5eacb721783bedfc3d4d02761be543a'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$dst = Join-Path $env:TEMP ('youtube-music-mcp-' + [Guid]::NewGuid().ToString('N'))
$ytmDir = Join-Path $dst 'youtube-music-mcp'
$bridgeDir = Join-Path $dst 'codex-chatgpt-bridge'
New-Item -ItemType Directory -Force -Path $ytmDir, $bridgeDir | Out-Null

try {
    Write-Host '[1/3] Downloading pinned YouTube Music MCP files'
    foreach ($name in @('server.py', 'auth.py', 'pyproject.toml', 'install.ps1')) {
        $uri = "https://raw.githubusercontent.com/$SourceRepo/$SourceRef/scripts/youtube-music-mcp/$name"
        Invoke-WebRequest -UseBasicParsing -Uri $uri -OutFile (Join-Path $ytmDir $name)
    }

    Write-Host '[2/3] Downloading pinned bridge allowlist files'
    foreach ($name in @('bridge-daemon.ps1', 'send-task.ps1')) {
        $uri = "https://raw.githubusercontent.com/$SourceRepo/$SourceRef/scripts/codex-chatgpt-bridge/$name"
        Invoke-WebRequest -UseBasicParsing -Uri $uri -OutFile (Join-Path $bridgeDir $name)
    }

    Write-Host '[3/3] Installing'
    $installer = Join-Path $ytmDir 'install.ps1'
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $installer)
    if (-not [string]::IsNullOrWhiteSpace($ClientSecret)) {
        $args += @('-ClientSecret', (Resolve-Path -LiteralPath $ClientSecret).Path)
    }

    & powershell.exe @args
    if ($LASTEXITCODE -ne 0) { throw "YouTube Music MCP installer failed with exit code $LASTEXITCODE" }
}
finally {
    Remove-Item -LiteralPath $dst -Recurse -Force -ErrorAction SilentlyContinue
}
