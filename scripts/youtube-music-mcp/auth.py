from __future__ import annotations

import argparse
import os
import shutil
from pathlib import Path

from google_auth_oauthlib.flow import InstalledAppFlow

YOUTUBE_SCOPE = "https://www.googleapis.com/auth/youtube"


def app_dir() -> Path:
    override = os.environ.get("YTM_MCP_HOME")
    if override:
        return Path(override)
    if os.environ.get("LOCALAPPDATA"):
        return Path(os.environ["LOCALAPPDATA"]) / "OpenAI" / "YouTubeMusicMCP"
    return Path.home() / ".local" / "share" / "OpenAI" / "YouTubeMusicMCP"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Authorize the local YouTube Music MCP through Google OAuth 2.0."
    )
    parser.add_argument(
        "client_secret",
        type=Path,
        help="OAuth 2.0 Desktop app client JSON downloaded from Google Cloud.",
    )
    args = parser.parse_args()

    source = args.client_secret.expanduser().resolve()
    if not source.is_file():
        raise SystemExit(f"Client secret JSON not found: {source}")

    root = app_dir()
    root.mkdir(parents=True, exist_ok=True)
    stored_client = root / "client_secret.json"
    token_path = root / "token.json"

    if source != stored_client.resolve():
        shutil.copy2(source, stored_client)

    flow = InstalledAppFlow.from_client_secrets_file(str(stored_client), scopes=[YOUTUBE_SCOPE])
    creds = flow.run_local_server(
        host="127.0.0.1",
        port=0,
        open_browser=True,
        access_type="offline",
        prompt="consent",
        success_message="YouTube Music MCP authorization complete. You can close this tab.",
    )
    token_path.write_text(creds.to_json(), encoding="utf-8")
    print(f"Saved OAuth token to: {token_path}")


if __name__ == "__main__":
    main()
