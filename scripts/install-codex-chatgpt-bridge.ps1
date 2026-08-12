param(
    [string]$Repo = '',
    [int]$Issue = 0,
    [string]$AllowedRoot = '',
    [int]$PollSeconds = 30,
    [string]$TaskName = 'OpenAI Codex ChatGPT Bridge',
    [string]$SourceRepo = 'KAFKA2306/KAFKA2306',
    [string]$SourceRef = '23640ccec32355cad91bb7cfeed34845db54824c'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Require-Command([string]$Name) {
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) { throw "Required command is not installed or not on PATH: $Name" }
    return $cmd
}

Write-Host '[1/5] Checking required CLIs'
$gh = Require-Command 'gh'
$codex = Require-Command 'codex'
Require-Command 'git' | Out-Null
& $gh.Source --version | Select-Object -First 1 | Write-Host
& $codex.Source --version | Write-Host

Write-Host '[2/5] Checking GitHub authentication'
& $gh.Source auth status --hostname github.com *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'GitHub CLI is not authenticated. Opening the official GitHub browser login flow...'
    & $gh.Source auth login --hostname github.com --git-protocol https --web
    if ($LASTEXITCODE -ne 0) { throw "gh auth login failed with exit code $LASTEXITCODE" }
}
& $gh.Source auth status --hostname github.com
if ($LASTEXITCODE -ne 0) { throw 'GitHub authentication is still not valid.' }

Write-Host '[3/5] Checking Codex authentication'
& $codex.Source login status | Out-Host
if ($LASTEXITCODE -ne 0) { throw 'Codex CLI is not authenticated. Run: codex login' }

Write-Host '[4/5] Downloading pinned public bridge files'
$dst = Join-Path $env:TEMP ('codex-chatgpt-bridge-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $dst | Out-Null
try {
    foreach ($name in @('install.ps1', 'bridge-daemon.ps1', 'bridge-supervisor.ps1', 'send-task.ps1')) {
        $uri = "https://raw.githubusercontent.com/$SourceRepo/$SourceRef/scripts/codex-chatgpt-bridge/$name"
        Invoke-WebRequest -UseBasicParsing -Uri $uri -OutFile (Join-Path $dst $name)
    }

    Write-Host '[5/5] Installing and running end-to-end smoke test'
    $installer = Join-Path $dst 'install.ps1'
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $installer, '-PollSeconds', $PollSeconds, '-TaskName', $TaskName)
    if ($Repo) { $args += @('-Repo', $Repo) }
    if ($Issue -gt 0) { $args += @('-Issue', $Issue) }
    if ($AllowedRoot) { $args += @('-AllowedRoot', $AllowedRoot) }

    & powershell.exe @args
    if ($LASTEXITCODE -ne 0) { throw "Bridge installer failed with exit code $LASTEXITCODE" }
}
finally {
    Remove-Item -LiteralPath $dst -Recurse -Force -ErrorAction SilentlyContinue
}
