param(
    [string]$Repo = '',
    [int]$Issue = 0,
    [string]$AllowedRoot = '',
    [int]$PollSeconds = 30,
    [string]$TaskName = 'OpenAI Codex ChatGPT Bridge',
    [string]$ControllerLogin = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Require-Command([string]$Name) {
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) { throw "Required command is not installed or not on PATH: $Name" }
    return $cmd
}

function Invoke-GhJson([string[]]$Args) {
    $out = & gh @Args
    if ($LASTEXITCODE -ne 0) { throw "gh command failed: gh $($Args -join ' ')" }
    return $out
}

function Post-QueueComment([string]$RepoName, [int]$IssueNumber, [string]$Body) {
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("codex-bridge-install-" + [Guid]::NewGuid().ToString('N') + '.md')
    try {
        Set-Content -LiteralPath $tmp -Value $Body -Encoding utf8
        & gh issue comment $IssueNumber --repo $RepoName --body-file $tmp | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "gh issue comment failed: $LASTEXITCODE" }
    }
    finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

Write-Host '[1/9] Checking required CLIs'
$gh = Require-Command 'gh'
$codex = Require-Command 'codex'
$git = Require-Command 'git'
Require-Command 'schtasks.exe' | Out-Null
& $gh.Source --version | Select-Object -First 1 | Write-Host
& $codex.Source --version | Write-Host

Write-Host '[2/9] Checking authentication'
& $gh.Source auth status --hostname github.com *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'GitHub CLI is not authenticated. Opening browser login...'
    & $gh.Source auth login --hostname github.com --git-protocol https --web
    if ($LASTEXITCODE -ne 0) { throw "gh auth login failed: $LASTEXITCODE" }
}
& $codex.Source login status | Out-Host
if ($LASTEXITCODE -ne 0) {
    throw 'Codex CLI is not authenticated. Run: codex login'
}

if (-not $ControllerLogin) {
    $ControllerLogin = ((Invoke-GhJson @('api', 'user', '--jq', '.login')) | Select-Object -First 1).Trim()
}
if (-not $ControllerLogin) { throw 'Could not determine GitHub login.' }

if (-not $Repo) { $Repo = "$ControllerLogin/codex-chatgpt-bridge-queue" }
if (-not $AllowedRoot) { $AllowedRoot = (Get-Location).Path }
$allowedRootItem = Get-Item -LiteralPath $AllowedRoot -ErrorAction Stop
if (-not $allowedRootItem.PSIsContainer) { throw "AllowedRoot is not a directory: $AllowedRoot" }
$AllowedRoot = [IO.Path]::GetFullPath($allowedRootItem.FullName).TrimEnd('\')

Write-Host '[3/9] Ensuring a private GitHub queue repository'
& $gh.Source repo view $Repo --json nameWithOwner,visibility *> $null
if ($LASTEXITCODE -ne 0) {
    & $gh.Source repo create $Repo --private --description 'Private queue for the ChatGPT ↔ Codex CLI bridge' | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "Could not create private queue repository: $Repo" }
}
$visibility = ((Invoke-GhJson @('repo', 'view', $Repo, '--json', 'visibility', '--jq', '.visibility')) | Select-Object -First 1).Trim()
if ($visibility -ne 'PRIVATE') { throw "Queue repository must be PRIVATE: $Repo is $visibility" }

Write-Host '[4/9] Ensuring the queue Issue'
$queueTitle = 'Codex ChatGPT Bridge Queue'
if ($Issue -le 0) {
    $issuesJson = Invoke-GhJson @('api', "repos/$Repo/issues?state=all&per_page=100")
    $issues = @($issuesJson | ConvertFrom-Json)
    $match = $issues | Where-Object { -not $_.pull_request -and $_.title -eq $queueTitle } | Select-Object -First 1
    if ($match) {
        $Issue = [int]$match.number
    }
    else {
        $body = @"
This private Issue is the transport queue for a local ChatGPT ↔ Codex CLI bridge.

Do not make this repository public. Controller comments are accepted only from the configured GitHub login.
"@
        $issueUrl = & $gh.Source issue create --repo $Repo --title $queueTitle --body $body
        if ($LASTEXITCODE -ne 0) { throw 'Failed to create bridge queue Issue.' }
        $Issue = [int](($issueUrl | Select-Object -Last 1).Trim().Split('/')[-1])
    }
}
& $gh.Source issue view $Issue --repo $Repo --json number,title,state | Out-Host
if ($LASTEXITCODE -ne 0) { throw "Cannot access $Repo issue #$Issue" }

Write-Host '[5/9] Installing bridge files'
$sourceDaemon = Join-Path $PSScriptRoot 'bridge-daemon.ps1'
$sourceSupervisor = Join-Path $PSScriptRoot 'bridge-supervisor.ps1'
$sourceSender = Join-Path $PSScriptRoot 'send-task.ps1'
foreach ($source in @($sourceDaemon, $sourceSupervisor, $sourceSender)) {
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing $source" }
}

$runtimeRoot = Join-Path $env:LOCALAPPDATA 'OpenAI\CodexChatGPTBridge'
New-Item -ItemType Directory -Force -Path $runtimeRoot | Out-Null
$daemon = Join-Path $runtimeRoot 'bridge-daemon.ps1'
$supervisor = Join-Path $runtimeRoot 'bridge-supervisor.ps1'
$sender = Join-Path $runtimeRoot 'send-task.ps1'
Copy-Item -LiteralPath $sourceDaemon -Destination $daemon -Force
Copy-Item -LiteralPath $sourceSupervisor -Destination $supervisor -Force
Copy-Item -LiteralPath $sourceSender -Destination $sender -Force

$config = [ordered]@{
    repo = $Repo
    issue = $Issue
    controller_login = $ControllerLogin
    allowed_root = $AllowedRoot
    poll_seconds = $PollSeconds
    installed_at = (Get-Date).ToUniversalTime().ToString('o')
}
$config | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $runtimeRoot 'config.json') -Encoding utf8

Write-Host '[6/9] Registering Windows logon task'
$taskCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$supervisor`" -Repo `"$Repo`" -Issue $Issue -ControllerLogin `"$ControllerLogin`" -AllowedRoot `"$AllowedRoot`" -PollSeconds $PollSeconds"
& schtasks.exe /Create /F /SC ONLOGON /TN $TaskName /TR $taskCommand /RL LIMITED | Out-Host
if ($LASTEXITCODE -ne 0) { throw "schtasks /Create failed: $LASTEXITCODE" }

Write-Host '[7/9] Starting bridge'
& schtasks.exe /End /TN $TaskName 2>$null | Out-Null
Start-Sleep -Seconds 1
& schtasks.exe /Run /TN $TaskName | Out-Host
if ($LASTEXITCODE -ne 0) { throw "schtasks /Run failed: $LASTEXITCODE" }

Write-Host '[8/9] Queueing an end-to-end smoke test'
$smokeRepo = Join-Path $runtimeRoot 'smoke-repo'
Remove-Item -LiteralPath $smokeRepo -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $smokeRepo | Out-Null
& $git.Source -C $smokeRepo init | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'git init for smoke test failed.' }

$taskId = 'smoke-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0, 8)
$spec = [ordered]@{
    cwd = $smokeRepo
    sandbox = 'read-only'
    prompt = 'This is an end-to-end transport smoke test. Do not create, modify, or delete any files. Reply with exactly: BRIDGE_OK'
} | ConvertTo-Json -Compress
$fence = '```'
$body = @(
    "<!-- codex-bridge:v1 role=controller task=$taskId -->",
    "## Bridge smoke test $taskId",
    '',
    ($fence + 'json'),
    $spec,
    $fence
) -join "`n"
Post-QueueComment -RepoName $Repo -IssueNumber $Issue -Body $body

Write-Host '[9/9] Verifying smoke-test result'
$deadline = (Get-Date).AddSeconds(180)
$ok = $false
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Seconds 5
    $commentsJson = Invoke-GhJson @('api', "repos/$Repo/issues/$Issue/comments?per_page=100")
    $comments = @($commentsJson | ConvertFrom-Json)
    $worker = $comments | Where-Object {
        $_.body -match [regex]::Escape("codex-bridge:v1 role=worker task=$taskId")
    } | Select-Object -Last 1
    if ($worker) {
        if ($worker.body -match 'BRIDGE_OK' -and $worker.body -match '"exit_code"\s*:\s*0') {
            $ok = $true
        }
        break
    }
}

if (-not $ok) {
    Write-Host "Queue: https://github.com/$Repo/issues/$Issue"
    Write-Host "Runtime: $runtimeRoot"
    throw "Smoke test did not return BRIDGE_OK with exit_code 0. Inspect the queue and $runtimeRoot\logs."
}

Write-Host ''
Write-Host 'BRIDGE_OK'
Write-Host "Queue: https://github.com/$Repo/issues/$Issue"
Write-Host "Runtime: $runtimeRoot"
Write-Host "Scheduled task: $TaskName"
Write-Host "Allowed root: $AllowedRoot"
Write-Host "Task sender: $sender"
Write-Host 'Default task sandbox: read-only. Use workspace-write only for tasks that must edit files.'
