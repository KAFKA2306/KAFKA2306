$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Require-Command([string]$Name) {
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "Required command is not installed or not on PATH: $Name"
    }
    return $cmd
}

Write-Host '[1/6] Checking required CLIs'
$gh = Require-Command 'gh'
$codex = Require-Command 'codex'
& $gh.Source --version | Select-Object -First 1 | Write-Host
& $codex.Source --version | Write-Host

Write-Host '[2/6] Checking GitHub authentication'
& $gh.Source auth status --hostname github.com *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'GitHub CLI is not authenticated. Opening the official GitHub browser login flow...'
    & $gh.Source auth login --hostname github.com --git-protocol https --web
    if ($LASTEXITCODE -ne 0) {
        throw "gh auth login failed with exit code $LASTEXITCODE"
    }
}

& $gh.Source auth status --hostname github.com
if ($LASTEXITCODE -ne 0) {
    throw 'GitHub authentication is still not valid.'
}

Write-Host '[3/6] Configuring Git to use GitHub CLI credentials'
& $gh.Source auth setup-git --hostname github.com
if ($LASTEXITCODE -ne 0) {
    throw "gh auth setup-git failed with exit code $LASTEXITCODE"
}

Write-Host '[4/6] Cloning private bridge repository'
$dst = Join-Path $env:TEMP 'basic_prompts-codex-bridge'
Remove-Item $dst -Recurse -Force -ErrorAction SilentlyContinue
& $gh.Source repo clone KAFKA2306/basic_prompts $dst
if ($LASTEXITCODE -ne 0) {
    throw "gh repo clone failed with exit code $LASTEXITCODE"
}

$installer = Join-Path $dst 'codex-chatgpt-bridge\install.ps1'
if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
    throw "Bridge installer was not found after clone: $installer"
}

Write-Host '[5/6] Installing the Codex ↔ ChatGPT bridge'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer
if ($LASTEXITCODE -ne 0) {
    throw "Bridge installer failed with exit code $LASTEXITCODE"
}

Write-Host '[6/6] Bootstrap complete'
Write-Host 'GitHub authentication is stored by GitHub CLI; no token was written by this bootstrap.'
Write-Host 'The bridge installer has been executed. Review its final health/smoke-test output above.'
