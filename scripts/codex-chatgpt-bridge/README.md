# ChatGPT ↔ Codex CLI Bridge

Windows のローカル Codex CLI に task を渡し、final result を private GitHub Issue 経由で ChatGPT から検証できるようにする bridge です。

```text
ChatGPT / send-task.ps1
        │ controller task
        ▼
private GitHub Issue
        │ gh CLI polling
        ▼
Windows bridge daemon
        │ codex exec
        ▼
local Codex CLI
        │ final response + exit code + bounded git evidence
        ▼
private GitHub Issue
        ▼
ChatGPT
```

## 1コマンド導入

Codex に触らせてよい親ディレクトリへ移動し、PowerShell で実行します。既定ではカレントディレクトリが `AllowedRoot` です。

```powershell
$bootstrap = Join-Path $env:TEMP 'install-codex-chatgpt-bridge.ps1'
Invoke-WebRequest -UseBasicParsing `
  -Uri 'https://raw.githubusercontent.com/KAFKA2306/KAFKA2306/5d28036dcc21c03f2c1a0468892ee83bff5a0489/scripts/install-codex-chatgpt-bridge.ps1' `
  -OutFile $bootstrap
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bootstrap
```

installer は GitHub / Codex 認証、private queue、daemon / supervisor / sender、logon Scheduled Task を構成し、read-only smoke task の `BRIDGE_OK` + `exit_code: 0` を成功条件にします。

## task を投げる

```powershell
$send = Join-Path $env:LOCALAPPDATA 'OpenAI\CodexChatGPTBridge\send-task.ps1'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $send `
  -Prompt 'このrepositoryを読み、問題の原因だけを調べて報告して' `
  -Cwd 'D:\dev\example'
```

既定は `read-only`。ファイル変更が必要な task だけ `-Sandbox workspace-write` を明示します。`danger-full-access` は受け付けません。

## local MCP allowlist

通常の autonomous run は常に次を維持します。

```text
--ignore-user-config --disable apps --disable plugins
```

local MCP は deny-by-default です。daemon に hard-code された名前だけを task 単位で opt-in できます。現在の allowlist は **`youtube_music` のみ**です。

YouTube Music MCP の導入は `../youtube-music-mcp/README.md` を参照してください。導入後は次のように明示します。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $send `
  -Prompt 'private playlistを作成し、曲を検索・確認して追加し、YouTube Music URLを返して' `
  -Cwd 'D:\dev\example' `
  -Mcp youtube_music
```

queue JSON では optional `mcp` field を使います。

```json
{
  "cwd": "D:\\dev\\example",
  "sandbox": "read-only",
  "mcp": ["youtube_music"],
  "prompt": "private playlistを作成してURLを返して"
}
```

未知のMCP名は `send-task.ps1` と daemon の両方で拒否します。`youtube_music` は local runtime と OAuth token が確認できない場合も起動を拒否します。

## Security boundary

- queue repository は private 必須
- controller comment は設定した GitHub login の投稿だけを受理
- `cwd` は install 時の `AllowedRoot` 配下だけ
- sandbox は `read-only` / `workspace-write` のみ、既定 `read-only`
- autonomous run は interactive Codex の user config / apps / plugins から分離
- local MCP は task の明示 opt-in + daemon の hard-coded allowlist の両方が必要
- GitHub token / Codex credential / OAuth token を Issue comment に保存しない
- raw Codex JSONL は local runtime にだけ保持
- result text は bounded、processed task ID も bounded

## Verification

```powershell
codex login status
gh auth status
schtasks.exe /Query /TN "OpenAI Codex ChatGPT Bridge" /V /FO LIST
Get-Content "$env:LOCALAPPDATA\OpenAI\CodexChatGPTBridge\logs\bridge.log" -Tail 100
```

成功条件は worker payload の `exit_code: 0` と final message `BRIDGE_OK` です。

## Primary sources

- OpenAI Codex non-interactive mode: https://learn.chatgpt.com/docs/non-interactive-mode
- OpenAI Codex MCP: https://learn.chatgpt.com/docs/extend/mcp?surface=cli
- OpenAI Codex config overrides: https://learn.chatgpt.com/docs/config-file/config-advanced
- GitHub CLI authentication: https://cli.github.com/manual/gh_auth_login
- ChatGPT GitHub app: https://help.openai.com/en/articles/11145903-connecting-github-to-chatgpt
