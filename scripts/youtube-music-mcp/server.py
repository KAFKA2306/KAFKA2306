from __future__ import annotations

import os
from pathlib import Path
from typing import Literal

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from mcp.server import MCPServer

YOUTUBE_SCOPE = "https://www.googleapis.com/auth/youtube"
MUSIC_TOPIC_ID = "/m/04rlf"

_app_root = os.environ.get("YTM_MCP_HOME")
if _app_root:
    APP_DIR = Path(_app_root)
elif os.environ.get("LOCALAPPDATA"):
    APP_DIR = Path(os.environ["LOCALAPPDATA"]) / "OpenAI" / "YouTubeMusicMCP"
else:
    APP_DIR = Path.home() / ".local" / "share" / "OpenAI" / "YouTubeMusicMCP"

TOKEN_PATH = APP_DIR / "token.json"

mcp = MCPServer(
    "YouTube Music",
    instructions=(
        "Search and verify tracks before adding them. Playlist creation defaults to private. "
        "Use only the authenticated user's playlists. This server exposes no delete tools."
    ),
)


def _load_credentials() -> Credentials:
    if not TOKEN_PATH.exists():
        raise RuntimeError(f"YouTube OAuth token not found at {TOKEN_PATH}. Run auth.py first.")

    creds = Credentials.from_authorized_user_file(str(TOKEN_PATH), [YOUTUBE_SCOPE])
    if creds.expired and creds.refresh_token:
        creds.refresh(Request())
        APP_DIR.mkdir(parents=True, exist_ok=True)
        TOKEN_PATH.write_text(creds.to_json(), encoding="utf-8")

    if not creds.valid:
        raise RuntimeError("YouTube OAuth credentials are invalid. Re-run auth.py.")

    return creds


def _youtube():
    return build("youtube", "v3", credentials=_load_credentials(), cache_discovery=False)


def _bounded(value: int, low: int, high: int) -> int:
    return max(low, min(high, value))


@mcp.tool()
def search_music(query: str, max_results: int = 5) -> dict:
    """Search YouTube for music-topic videos. Read-only."""
    count = _bounded(max_results, 1, 25)
    response = (
        _youtube()
        .search()
        .list(part="snippet", q=query, type="video", topicId=MUSIC_TOPIC_ID, maxResults=count)
        .execute()
    )

    results = []
    for item in response.get("items", []):
        video_id = item["id"]["videoId"]
        snippet = item["snippet"]
        results.append(
            {
                "video_id": video_id,
                "title": snippet.get("title"),
                "channel_title": snippet.get("channelTitle"),
                "published_at": snippet.get("publishedAt"),
                "youtube_url": f"https://www.youtube.com/watch?v={video_id}",
                "youtube_music_url": f"https://music.youtube.com/watch?v={video_id}",
            }
        )
    return {"query": query, "results": results}


@mcp.tool()
def create_playlist(
    title: str,
    description: str = "",
    privacy: Literal["private", "unlisted", "public"] = "private",
) -> dict:
    """Create a playlist owned by the authenticated user."""
    created = (
        _youtube()
        .playlists()
        .insert(
            part="snippet,status",
            body={
                "snippet": {"title": title, "description": description},
                "status": {"privacyStatus": privacy},
            },
        )
        .execute()
    )
    playlist_id = created["id"]
    return {
        "playlist_id": playlist_id,
        "title": created["snippet"]["title"],
        "privacy": created["status"]["privacyStatus"],
        "youtube_url": f"https://www.youtube.com/playlist?list={playlist_id}",
        "youtube_music_url": f"https://music.youtube.com/playlist?list={playlist_id}",
    }


@mcp.tool()
def add_video_to_playlist(playlist_id: str, video_id: str, position: int | None = None) -> dict:
    """Add a verified YouTube video ID to an existing playlist."""
    snippet: dict = {
        "playlistId": playlist_id,
        "resourceId": {"kind": "youtube#video", "videoId": video_id},
    }
    if position is not None:
        if position < 0:
            raise ValueError("position must be zero or greater")
        snippet["position"] = position

    created = (
        _youtube()
        .playlistItems()
        .insert(part="snippet", body={"snippet": snippet})
        .execute()
    )
    return {
        "playlist_item_id": created["id"],
        "playlist_id": playlist_id,
        "video_id": video_id,
        "position": created["snippet"].get("position"),
    }


@mcp.tool()
def list_my_playlists(max_results: int = 25) -> dict:
    """List playlists owned by the authenticated user. Read-only."""
    count = _bounded(max_results, 1, 50)
    response = (
        _youtube()
        .playlists()
        .list(part="snippet,status", mine=True, maxResults=count)
        .execute()
    )
    playlists = []
    for item in response.get("items", []):
        playlist_id = item["id"]
        playlists.append(
            {
                "playlist_id": playlist_id,
                "title": item["snippet"].get("title"),
                "privacy": item.get("status", {}).get("privacyStatus"),
                "youtube_music_url": f"https://music.youtube.com/playlist?list={playlist_id}",
            }
        )
    return {"playlists": playlists, "next_page_token": response.get("nextPageToken")}


@mcp.tool()
def list_playlist_items(playlist_id: str, max_results: int = 50) -> dict:
    """List videos in a playlist. Read-only."""
    count = _bounded(max_results, 1, 50)
    response = (
        _youtube()
        .playlistItems()
        .list(part="snippet,contentDetails", playlistId=playlist_id, maxResults=count)
        .execute()
    )
    items = []
    for item in response.get("items", []):
        snippet = item["snippet"]
        video_id = item.get("contentDetails", {}).get("videoId")
        items.append(
            {
                "playlist_item_id": item["id"],
                "video_id": video_id,
                "title": snippet.get("title"),
                "channel_title": snippet.get("videoOwnerChannelTitle"),
                "position": snippet.get("position"),
                "youtube_music_url": f"https://music.youtube.com/watch?v={video_id}" if video_id else None,
            }
        )
    return {"items": items, "next_page_token": response.get("nextPageToken")}


if __name__ == "__main__":
    mcp.run()
