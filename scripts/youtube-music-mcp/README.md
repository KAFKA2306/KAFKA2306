# YouTube Music MCP

Windows 上の Codex / ChatGPT-Codex bridge から、公式 **YouTube Data API v3** を使って YouTube / YouTube Music の playlist を扱う local MCP server です。

YouTube Music 専用の非公式APIへ依存せず、Google公式APIだけを使います。YouTube Help では playlist は YouTube Music と YouTube の両方に表示され、YouTube側で作成した playlist は YouTube Music では music video のみが表示されると説明されています。

## 公開するtool

- `search_music` — music topic に限定した動画検索
- `list_my_playlists` — 自分のplaylist一覧
- `list_playlist_items` — playlist内容確認
- `create_playlist` — playlist作成。既定は `private`
- `add_video_to_playlist` — 検証済み video ID をplaylistへ追加

削除toolは公開しません。

## セキュリティ境界

- OAuth client JSON / token はGitHubへ保存しない
- Windowsでは `%LOCALAPPDATA%\OpenAI\YouTubeMusicMCP` にだけ保存
- OAuth scope は `https://www.googleapis.com/auth/youtube`
- playlist作成は既定 `private`
- normal interactive Codex には `youtube_music` として登録
- ChatGPT-Codex bridge は従来どおり `--ignore-user-config` を維持
- bridge task の JSON に `"mcp":["youtube_music"]` が明示された場合だけ、このMCPをone-off configで注入
- bridgeから公開するMCP名はhard-coded allowlistで、未知のMCP名は拒否

## Google側の1回だけの設定

1. Google Cloud project を作成または選択
2. **YouTube Data API v3** を有効化
3. Google Auth / OAuth consent screen を設定
4. OAuth client を **Desktop app** として作成
5. client JSON をWindowsへ保存

Google公式のInstalled App OAuthはbrowserで本人が認可し、local loopback redirectを使います。`auth.py` はこの方式を使います。

## 1コマンド導入

Googleのclient JSONがまだ無い場合は、先にMCP本体だけ入れられます。

```powershell
$bootstrap = Join-Path $env:TEMP 'install-youtube-music-mcp.ps1'
Invoke-WebRequest -UseBasicParsing `
  -Uri 'https://raw.githubusercontent.com/KAFKA2306/KAFKA2306/bc4201e54b4173c9ad9d7551903f36e36b396109/scripts/install-youtube-music-mcp.ps1' `
  -OutFile $bootstrap
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bootstrap
```

client JSON がある場合は同じbootstrapへ渡します。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bootstrap `
  -ClientSecret 'C:\path\to\client_secret.json'
```

installer は次を行います。

1. `%LOCALAPPDATA%\OpenAI\YouTubeMusicMCP` にlocal runtimeを作成
2. `uv` でPython 3.12環境と依存を同期
3. `codex mcp add youtube_music -- ...` でinteractive Codexへ登録
4. `-ClientSecret` があればbrowser OAuthを実行しtokenをlocal保存
5. 既存ChatGPT-Codex bridgeが導入済みなら、MCP allowlist対応daemon / `send-task.ps1` を更新してScheduled Taskを再起動
6. `codex mcp list` で登録を確認

## OAuthを後から行う

```powershell
$root = Join-Path $env:LOCALAPPDATA 'OpenAI\YouTubeMusicMCP'
& "$root\.venv\Scripts\python.exe" "$root\auth.py" 'C:\path\to\client_secret.json'
```

## bridgeから使う

local helperでは `-Mcp youtube_music` を明示します。

```powershell
$send = Join-Path $env:LOCALAPPDATA 'OpenAI\CodexChatGPTBridge\send-task.ps1'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $send `
  -Prompt 'KAFKA // DEEP WORK というprivate playlistを作成し、曲を検索・確認して追加し、最後にYouTube Music URLを返して' `
  -Cwd 'D:\work' `
  -Mcp youtube_music
```

ChatGPTがprivate queueへcontroller taskを直接投稿する場合は、task JSONを次の形にします。

```json
{
  "cwd": "D:\\work",
  "sandbox": "read-only",
  "mcp": ["youtube_music"],
  "prompt": "Create the requested private YouTube Music playlist and return its URL."
}
```

MCPによるYouTube accountへのplaylist書き込みはfilesystem sandboxとは別の明示的なtool操作です。`mcp` opt-in が無いbridge taskにはtool自体を公開しません。

## 一次情報

- YouTube Data API `playlists.insert`: https://developers.google.com/youtube/v3/docs/playlists/insert
- YouTube Data API `playlistItems.insert`: https://developers.google.com/youtube/v3/docs/playlistItems/insert
- YouTube Data API `search.list`: https://developers.google.com/youtube/v3/docs/search/list
- Google OAuth 2.0 for installed apps: https://developers.google.com/identity/protocols/oauth2/native-app
- Google OAuth scopes: https://developers.google.com/identity/protocols/oauth2/scopes#youtube
- YouTube Music playlist help: https://support.google.com/youtubemusic/answer/7205933
- OpenAI Codex MCP: https://learn.chatgpt.com/docs/extend/mcp?surface=cli
- OpenAI Codex one-off config overrides: https://learn.chatgpt.com/docs/config-file/config-advanced
- MCP Python SDK v2: https://github.com/modelcontextprotocol/python-sdk
