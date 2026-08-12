param(
    [Parameter(Mandatory = $true)][string]$Repo,
    [Parameter(Mandatory = $true)][int]$Issue,
    [Parameter(Mandatory = $true)][string]$ControllerLogin,
    [Parameter(Mandatory = $true)][string]$AllowedRoot,
    [int]$PollSeconds = 30
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$runtimeRoot = Join-Path $env:LOCALAPPDATA 'OpenAI\CodexChatGPTBridge'
$statePath = Join-Path $runtimeRoot 'state.json'
$logDir = Join-Path $runtimeRoot 'logs'
New-Item -ItemType Directory -Force -Path $runtimeRoot, $logDir | Out-Null

function Write-BridgeLog([string]$Message) {
    Add-Content -Path (Join-Path $logDir 'bridge.log') -Value "$(Get-Date -Format o) $Message" -Encoding utf8
}

function Load-State {
    if (-not (Test-Path -LiteralPath $statePath)) { return @{ processed = @() } }
    try {
        $obj = Get-Content -Raw -LiteralPath $statePath | ConvertFrom-Json
        return @{ processed = @($obj.processed) }
    }
    catch {
        Write-BridgeLog "state load failed: $($_.Exception.Message)"
        return @{ processed = @() }
    }
}

function Save-State($State) {
    $State.processed = @($State.processed | Select-Object -Last 1000)
    $State | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $statePath -Encoding utf8
}

function Post-Comment([string]$Body) {
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("codex-bridge-comment-" + [Guid]::NewGuid().ToString('N') + '.md')
    try {
        Set-Content -LiteralPath $tmp -Value $Body -Encoding utf8
        & gh issue comment $Issue --repo $Repo --body-file $tmp | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "gh issue comment failed: $LASTEXITCODE" }
    }
    finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

function Normalize-Directory([string]$Path) {
    $item = Get-Item -LiteralPath $Path -ErrorAction Stop
    if (-not $item.PSIsContainer) { throw "Not a directory: $Path" }
    return [IO.Path]::GetFullPath($item.FullName).TrimEnd('\')
}

$allowedRootResolved = Normalize-Directory $AllowedRoot
$runtimeRootResolved = Normalize-Directory $runtimeRoot

function Test-UnderRoot([string]$Path, [string]$Root) {
    $candidate = [IO.Path]::GetFullPath($Path).TrimEnd('\')
    if ($candidate.Equals($Root, [StringComparison]::OrdinalIgnoreCase)) { return $true }
    return $candidate.StartsWith($Root + '\', [StringComparison]::OrdinalIgnoreCase)
}

function Get-GitEvidence([string]$Cwd) {
    $e = [ordered]@{ repo_root = $null; head = $null; status = @() }
    Push-Location $Cwd
    try {
        $rootText = (& git rev-parse --show-toplevel 2>$null)
        if ($LASTEXITCODE -eq 0) {
            $e.repo_root = ($rootText | Select-Object -First 1)
            $headText = (& git rev-parse HEAD 2>$null)
            if ($LASTEXITCODE -eq 0) { $e.head = ($headText | Select-Object -First 1) }
            $statusText = @(& git status --porcelain=v1 2>$null)
            if ($LASTEXITCODE -eq 0) { $e.status = @($statusText | Select-Object -First 200) }
        }
    }
    finally {
        Pop-Location
    }
    return $e
}

function Get-RequestedMcpNames($Spec) {
    if ($null -eq $Spec.PSObject.Properties['mcp']) { return @() }

    $names = @($Spec.mcp | ForEach-Object { [string]$_ })
    foreach ($name in $names) {
        if ($name -ne 'youtube_music') { throw "Unsupported bridge MCP: $name" }
    }
    return $names
}

function ConvertTo-TomlLiteral([string]$Value) {
    if ($Value.Contains("'")) { throw "MCP path cannot contain a single quote: $Value" }
    return "'$Value'"
}

function Get-CodexMcpArgs($Spec) {
    $names = @(Get-RequestedMcpNames $Spec)
    if ($names.Count -eq 0) { return @() }

    $args = @()
    if ($names -contains 'youtube_music') {
        $ytmRoot = Join-Path $env:LOCALAPPDATA 'OpenAI\YouTubeMusicMCP'
        $pythonExe = Join-Path $ytmRoot '.venv\Scripts\python.exe'
        $serverPath = Join-Path $ytmRoot 'server.py'
        $tokenPath = Join-Path $ytmRoot 'token.json'

        if (-not (Test-Path -LiteralPath $pythonExe -PathType Leaf)) {
            throw "youtube_music MCP is not installed: $pythonExe"
        }
        if (-not (Test-Path -LiteralPath $serverPath -PathType Leaf)) {
            throw "youtube_music MCP server is missing: $serverPath"
        }
        if (-not (Test-Path -LiteralPath $tokenPath -PathType Leaf)) {
            throw "youtube_music OAuth is not configured: $tokenPath"
        }

        $commandValue = ConvertTo-TomlLiteral $pythonExe
        $serverValue = ConvertTo-TomlLiteral $serverPath
        $enabledTools = '["search_music","create_playlist","add_video_to_playlist","list_my_playlists","list_playlist_items"]'.Replace('\"', '"')
        $approvalMode = 'mcp_servers.youtube_music.default_tools_approval_mode="approve"'.Replace('\"', '"')

        $args += @(
            '--config', "mcp_servers.youtube_music.command=$commandValue",
            '--config', "mcp_servers.youtube_music.args=[$serverValue]",
            '--config', 'mcp_servers.youtube_music.enabled=true',
            '--config', 'mcp_servers.youtube_music.required=true',
            '--config', "mcp_servers.youtube_music.enabled_tools=$enabledTools",
            '--config', $approvalMode
        )
    }
    return $args
}

function Run-CodexTask([string]$TaskId, $Spec) {
    if (-not $Spec.cwd -or -not $Spec.prompt) { throw 'Task JSON must contain cwd and prompt.' }

    $cwd = Normalize-Directory ([string]$Spec.cwd)
    if (-not (Test-UnderRoot $cwd $allowedRootResolved) -and -not (Test-UnderRoot $cwd $runtimeRootResolved)) {
        throw "cwd is outside AllowedRoot: $cwd"
    }

    $sandbox = 'read-only'
    if ($null -ne $Spec.sandbox -and [string]$Spec.sandbox) { $sandbox = [string]$Spec.sandbox }
    if ($sandbox -notin @('read-only', 'workspace-write')) {
        throw "sandbox must be read-only or workspace-write; received: $sandbox"
    }

    $taskDir = Join-Path $runtimeRoot ('tasks\' + $TaskId)
    New-Item -ItemType Directory -Force -Path $taskDir | Out-Null
    $lastMessage = Join-Path $taskDir 'last-message.txt'
    $events = Join-Path $taskDir 'events.jsonl'
    $promptText = [string]$Spec.prompt
    if ($promptText.Length -gt 60000) { throw 'prompt exceeds 60000 characters.' }

    $mcpNames = @(Get-RequestedMcpNames $Spec)
    $mcpArgs = @(Get-CodexMcpArgs $Spec)
    $mcpLog = if ($mcpNames.Count -gt 0) { $mcpNames -join ',' } else { 'none' }

    Write-BridgeLog "task=$TaskId cwd=$cwd sandbox=$sandbox mcp=$mcpLog starting"
    Push-Location $cwd
    try {
        # Keep autonomous runs independent from interactive Codex user config,
        # app discovery, and plugin discovery. Interactive Codex is untouched.
        # Only an explicitly requested, hard-coded MCP allowlist can be injected.
        $codexArgs = @(
            'exec',
            '--ignore-user-config',
            '--disable', 'apps',
            '--disable', 'plugins',
            '--sandbox', $sandbox
        ) + $mcpArgs + @(
            '--json',
            '--output-last-message', $lastMessage,
            '-'
        )

        $promptText | & codex @codexArgs 2>&1 |
            Tee-Object -FilePath $events | Out-Null
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    $text = if (Test-Path -LiteralPath $lastMessage) { Get-Content -Raw -LiteralPath $lastMessage } else { '' }
    if ($text.Length -gt 45000) { $text = $text.Substring(0, 45000) + "`n...[truncated]" }
    $git = Get-GitEvidence $cwd

    $payload = [ordered]@{
        task_id = $TaskId
        exit_code = $exitCode
        sandbox = $sandbox
        mcp = @($mcpNames)
        cwd = $cwd
        git = $git
        finished_at = (Get-Date).ToUniversalTime().ToString('o')
    } | ConvertTo-Json -Depth 6

    $fence = '```'
    $body = @(
        "<!-- codex-bridge:v1 role=worker task=$TaskId -->",
        "## Codex result $TaskId",
        '',
        ($fence + 'json'),
        $payload,
        $fence,
        '',
        '### Final message',
        '',
        $text
    ) -join "`n"

    Post-Comment $body
    Write-BridgeLog "task=$TaskId exit=$exitCode posted"
}

& gh auth status --hostname github.com | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'GitHub CLI is not authenticated.' }
& codex --version | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Codex CLI is not available.' }

Write-BridgeLog "daemon started repo=$Repo issue=$Issue controller=$ControllerLogin root=$allowedRootResolved poll=${PollSeconds}s"

while ($true) {
    try {
        $state = Load-State
        $processed = New-Object 'System.Collections.Generic.HashSet[string]'
        foreach ($id in @($state.processed)) {
            if ($null -ne $id) { [void]$processed.Add([string]$id) }
        }

        $pagesJson = & gh api "repos/$Repo/issues/$Issue/comments?per_page=100" --paginate --slurp
        if ($LASTEXITCODE -ne 0) { throw "gh api comments failed: $LASTEXITCODE" }
        $pages = @($pagesJson | ConvertFrom-Json)
        $comments = @()
        foreach ($page in $pages) { $comments += @($page) }

        foreach ($comment in ($comments | Sort-Object id)) {
            if ([string]$comment.user.login -ne $ControllerLogin) { continue }
            $body = [string]$comment.body
            $header = [regex]::Match($body, '<!--\s*codex-bridge:v1\s+role=controller\s+task=(?<task>[A-Za-z0-9._:-]+)\s*-->')
            if (-not $header.Success) { continue }
            $jsonBlock = [regex]::Match($body, '(?s)```json\s*(?<json>.*?)\s*```')
            if (-not $jsonBlock.Success) { continue }

            $taskId = $header.Groups['task'].Value
            if ($processed.Contains($taskId)) { continue }

            try {
                $spec = $jsonBlock.Groups['json'].Value | ConvertFrom-Json
                Run-CodexTask -TaskId $taskId -Spec $spec
            }
            catch {
                $err = $_.Exception.Message
                Write-BridgeLog "task=$taskId failed: $err"
                $errorBody = @(
                    "<!-- codex-bridge:v1 role=worker task=$taskId -->",
                    "## Codex bridge error $taskId",
                    '',
                    $err
                ) -join "`n"
                Post-Comment $errorBody
            }
            finally {
                [void]$processed.Add($taskId)
                $state.processed = @($processed)
                Save-State $state
            }
        }
    }
    catch {
        Write-BridgeLog "poll failed: $($_.Exception.Message)"
    }

    Start-Sleep -Seconds $PollSeconds
}
