# ChatGPT ↔ Codex CLI Bridge

Windows 上のローカル Codex CLI の最終結果を private GitHub Issue に返し、ChatGPT 側から読めるようにする bridge です。

目的は、Codex の実行結果を毎回チャットへコピー＆ペーストする作業をなくすことです。

## 何が自動化されるか

```text
PowerShell / write-capable ChatGPT action
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
        │ ChatGPT GitHub read
        ▼
ChatGPT
```

公開版は次の2モードを分けています。

1. **Result bridge（標準）**
   - ローカルの `send-task.ps1` から task を投入
   - Codex の結果を private Issue へ返す
   - ChatGPT は GitHub app 経由で結果を読む
2. **Bidirectional bridge（任意）**
   - ChatGPT 側に GitHub Issue comment の write action がある場合だけ、ChatGPT 自身が controller task を投稿できる

OpenAI の通常の GitHub app は公式 Help Center 上で read-only と説明されているため、write action が無い環境でも動く Result bridge を正準線にしています。

## 前提

- Windows
- Git
- GitHub CLI (`gh`)
- OpenAI Codex CLI (`codex`)
- GitHub アカウント
- Codex のログイン済み状態

公式:

- Codex CLI: https://github.com/openai/codex
- GitHub CLI auth: https://cli.github.com/manual/gh_auth_login
- ChatGPT GitHub app: https://help.openai.com/en/articles/11145903-connecting-github-to-chatgpt

## 1コマンド導入

Codex に触らせてよい親ディレクトリへ移動してから PowerShell で実行します。既定では、そのカレントディレクトリが `AllowedRoot` になります。

```powershell
$bootstrap = Join-Path $env:TEMP 'install-codex-chatgpt-bridge.ps1'
Invoke-WebRequest -UseBasicParsing `
  -Uri 'https://raw.githubusercontent.com/KAFKA2306/KAFKA2306/7405e79a2f15d38c455d652e3f91f2b04269b42a/scripts/install-codex-chatgpt-bridge.ps1' `
  -OutFile $bootstrap
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bootstrap
```

installer は次を行います。

1. `gh` / `codex` / `git` / Windows Scheduled Tasks を確認
2. GitHub と Codex の認証状態を確認
3. `<GitHub login>/codex-chatgpt-bridge-queue` を **private repository** として作成または再利用
4. `Codex ChatGPT Bridge Queue` Issue を作成または再利用
5. daemon / supervisor / task sender を `%LOCALAPPDATA%\OpenAI\CodexChatGPTBridge` に配置
6. logon Scheduled Task を登録
7. bridge を起動
8. baseline commit を持つ temporary Git repository で read-only smoke task を投入
9. worker の `BRIDGE_OK` + `exit_code: 0` を確認

smoke test が通らない場合、installer は成功扱いにせず停止します。

## task を投げる

install 後は次の helper を使えます。

```powershell
$send = Join-Path $env:LOCALAPPDATA 'OpenAI\CodexChatGPTBridge\send-task.ps1'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $send `
  -Prompt 'このrepositoryを読み、テスト失敗の原因だけを調べて報告して' `
  -Cwd 'D:\dev\example'
```

既定は `read-only` sandbox です。

ファイル変更が必要な task のみ明示的に `workspace-write` を指定します。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $send `
  -Prompt '失敗しているテストを最小修正で直し、テストを実行して' `
  -Cwd 'D:\dev\example' `
  -Sandbox workspace-write
```

公開 bridge は `danger-full-access` を受け付けません。

## Queue protocol

controller:

````md
<!-- codex-bridge:v1 role=controller task=task-unique-id -->

```json
{"cwd":"D:\\dev\\example","sandbox":"read-only","prompt":"調査内容"}
```
````

worker:

```md
<!-- codex-bridge:v1 role=worker task=task-unique-id -->
```

worker result には次を含めます。

- Codex exit code
- sandbox
- absolute cwd
- Git repository root（取得可能な場合）
- HEAD SHA（取得可能な場合）
- bounded `git status --porcelain=v1`
- Codex の final message

raw JSONL event stream はローカル runtime directory にだけ保持します。

## Security boundary

公開版では、便利さより先に境界を固定しています。

- queue repository は private でなければ installer が拒否
- controller comment は設定した GitHub login の投稿だけを受理
- `cwd` は install 時に設定した `AllowedRoot` 配下だけを許可
- smoke test 用 runtime directory は例外として許可
- sandbox は `read-only` / `workspace-write` のみ
- 既定は `read-only`
- autonomous run は `--ignore-user-config --disable apps --disable plugins` で interactive Codex の user config / app / plugin discovery から分離
- GitHub token や Codex credential を Issue comment へコピーしない
- result text は 45,000 characters で上限を設ける
- processed task ID はローカル state に保持し、最新 1,000 件に制限

OpenAI Codex CLI の non-interactive mode は `codex exec` を提供し、sandbox を明示できます。公式ドキュメントを参照してください。

- https://developers.openai.com/codex/noninteractive
- https://developers.openai.com/codex/cli/reference

## ChatGPT 側

ChatGPT の GitHub app を queue repository に接続すると、worker result を ChatGPT から検索・参照できます。

OpenAI 公式 Help Center では GitHub app は read-only とされています。したがって、標準構成では task 投入は `send-task.ps1` が担当します。

ChatGPT 側に GitHub Issues の write action を提供する plugin / app / workspace integration が存在し、その action が明示的に許可されている場合だけ、同じ controller protocol を使って ChatGPT から task を投入できます。

Scheduled Tasks は、アカウントや workspace で利用可能な app を参照して定期チェックできます。ただし availability / permissions は plan と workspace 設定に依存します。

公式:

- GitHub app: https://help.openai.com/en/articles/11145903-connecting-github-to-chatgpt
- Apps in ChatGPT: https://help.openai.com/en/articles/11487775-apps-in-chatgpt
- Scheduled Tasks: https://help.openai.com/en/articles/10291617-tasks-inchatgpt

## Troubleshooting

### GitHub authentication

```powershell
gh auth status
```

未認証なら:

```powershell
gh auth login --hostname github.com --git-protocol https --web
```

### Codex authentication

```powershell
codex login status
```

### Scheduled Task

```powershell
schtasks.exe /Query /TN "OpenAI Codex ChatGPT Bridge" /V /FO LIST
```

### Logs

```powershell
Get-Content "$env:LOCALAPPDATA\OpenAI\CodexChatGPTBridge\logs\bridge.log" -Tail 100
Get-Content "$env:LOCALAPPDATA\OpenAI\CodexChatGPTBridge\logs\supervisor.log" -Tail 100
```

### MCP / app / plugin の認証で smoke test が落ちる

bridge の autonomous run は interactive Codex の追加機能に依存しないよう、次を指定しています。

```text
--ignore-user-config --disable apps --disable plugins
```

interactive Codex の設定自体は変更しません。

## Success criterion

installer の最後が次で終わることだけを成功条件にします。

```text
BRIDGE_OK
```

かつ worker payload の `exit_code` が `0` であることを確認します。
