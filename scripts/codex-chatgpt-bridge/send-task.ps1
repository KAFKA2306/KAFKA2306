param(
    [Parameter(Mandatory = $true)][string]$Prompt,
    [string]$Cwd = (Get-Location).Path,
    [ValidateSet('read-only', 'workspace-write')][string]$Sandbox = 'read-only',
    [ValidateSet('youtube_music')][string[]]$Mcp = @()
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Join-Path $env:LOCALAPPDATA 'OpenAI\CodexChatGPTBridge'
$configPath = Join-Path $root 'config.json'
if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    throw "Bridge config not found: $configPath. Run the bridge installer first."
}

$config = Get-Content -Raw -LiteralPath $configPath | ConvertFrom-Json
if (-not $config.repo -or -not $config.issue -or -not $config.allowed_root) {
    throw 'Bridge config is incomplete. Re-run the installer.'
}

$item = Get-Item -LiteralPath $Cwd -ErrorAction Stop
if (-not $item.PSIsContainer) { throw "Cwd is not a directory: $Cwd" }
$cwdResolved = [IO.Path]::GetFullPath($item.FullName).TrimEnd('\')
$allowedRoot = [IO.Path]::GetFullPath([string]$config.allowed_root).TrimEnd('\')
$underRoot = $cwdResolved.Equals($allowedRoot, [StringComparison]::OrdinalIgnoreCase) -or
    $cwdResolved.StartsWith($allowedRoot + '\', [StringComparison]::OrdinalIgnoreCase)
if (-not $underRoot) { throw "Cwd is outside configured allowed_root: $allowedRoot" }

& gh auth status --hostname github.com *> $null
if ($LASTEXITCODE -ne 0) { throw 'GitHub CLI is not authenticated. Run: gh auth login' }

$taskId = 'task-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0, 8)
$taskSpec = [ordered]@{
    cwd = $cwdResolved
    sandbox = $Sandbox
    prompt = $Prompt
}
if ($Mcp.Count -gt 0) {
    $taskSpec.mcp = @($Mcp)
}
$spec = $taskSpec | ConvertTo-Json -Compress

$fence = '```'
$body = @(
    "<!-- codex-bridge:v1 role=controller task=$taskId -->",
    "## Codex task $taskId",
    '',
    ($fence + 'json'),
    $spec,
    $fence
) -join "`n"

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("codex-bridge-send-" + [Guid]::NewGuid().ToString('N') + '.md')
try {
    Set-Content -LiteralPath $tmp -Value $body -Encoding utf8
    & gh issue comment ([int]$config.issue) --repo ([string]$config.repo) --body-file $tmp | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "gh issue comment failed: $LASTEXITCODE" }
}
finally {
    Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
}

Write-Host "Queued: $taskId"
Write-Host "Queue: https://github.com/$($config.repo)/issues/$($config.issue)"
Write-Host "Sandbox: $Sandbox"
Write-Host "MCP: $(if ($Mcp.Count -gt 0) { $Mcp -join ',' } else { 'none' })"
Write-Host "Cwd: $cwdResolved"
