#!/usr/bin/env python3
"""
add_to_playlist.py

Add videos (from a TSV of VIDEO_ID<TAB>TITLE) to a target YouTube playlist.

Requirements:
    pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib

Setup:
    1) Create a Google Cloud project: https://console.cloud.google.com/
    2) Enable "YouTube Data API v3" for the project.
    3) Create OAuth 2.0 Client ID credentials of type "Desktop app".
    4) Download the JSON and save it as client_secret.json in the same directory as this script.
    5) First run will open a browser to authorize. Tokens are cached in token.json.

Quota note:
    Each playlistItems.insert costs 50 units. Default daily quota is 10,000 units (~200 inserts/day).
    Use --daily-limit to cap how many inserts the script attempts per run. Re-run on subsequent days to finish.

Usage:
    python add-to-youtube-playlist.py --playlist PLAYLIST_ID --tsv playlist.tsv --daily-limit 200
"""

import argparse
import csv
import sys
import time
from pathlib import Path

from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

SCOPES = ["https://www.googleapis.com/auth/youtube"]


def get_service():
    creds = None
    token_path = Path("token.json")
    if token_path.exists():
        creds = Credentials.from_authorized_user_file(str(token_path), SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file("client_secret.json", SCOPES)
            creds = flow.run_local_server(port=0, prompt="consent", authorization_prompt_message="")
        token_path.write_text(creds.to_json())
    return build("youtube", "v3", credentials=creds, static_discovery=False)


def read_tsv(tsv_path):
    items = []
    with open(tsv_path, newline="", encoding="utf-8") as f:
        reader = csv.reader(f, delimiter="\t")
        for row in reader:
            if not row:
                continue
            vid = row[0].strip()
            title = row[1].strip() if len(row) > 1 else ""
            if vid:
                items.append((vid, title))
    return items


def list_existing_video_ids(youtube, playlist_id):
    existing = set()
    page_token = None
    while True:
        resp = youtube.playlistItems().list(
            part="contentDetails",
            playlistId=playlist_id,
            maxResults=50,
            pageToken=page_token,
        ).execute()
        for item in resp.get("items", []):
            vid = item["contentDetails"].get("videoId")
            if vid:
                existing.add(vid)
        page_token = resp.get("nextPageToken")
        if not page_token:
            break
    return existing


def insert_video(youtube, playlist_id, video_id):
    body = {
        "snippet": {
            "playlistId": playlist_id,
            "resourceId": {
                "kind": "youtube#video",
                "videoId": video_id
            }
        }
    }
    return youtube.playlistItems().insert(part="snippet", body=body).execute()


def main():
    ap = argparse.ArgumentParser(description="Add TSV-listed videos to a YouTube playlist.")
    ap.add_argument("--playlist", required=True, help="Destination playlist ID (PL...)")
    ap.add_argument("--tsv", required=True, help="Path to TSV file: VIDEO_ID<TAB>TITLE")
    ap.add_argument("--daily-limit", type=int, default=180, help="Max inserts this run (default 180 ~ 9000 quota)")
    ap.add_argument("--sleep", type=float, default=0.2, help="Sleep between inserts (seconds)")
    args = ap.parse_args()

    youtube = get_service()

    print(f"Reading TSV: {args.tsv}")
    items = read_tsv(args.tsv)
    print(f"Loaded {len(items)} rows.")

    print("Fetching existing videos in destination playlist (to avoid duplicates)...")
    existing = list_existing_video_ids(youtube, args.playlist)
    print(f"Destination already contains {len(existing)} videos.")

    todo = [vid for vid, _ in items if vid not in existing]
    print(f"{len(todo)} videos to add after de-duplication.")

    added = 0
    failures = []

    for idx, video_id in enumerate(todo, 1):
        if added >= args.daily_limit:
            print(f"Reached daily limit of {args.daily_limit}. Stopping for today.")
            break
        try:
            insert_video(youtube, args.playlist, video_id)
            added += 1
            if (added % 25) == 0:
                print(f"Added {added} so far...")
            time.sleep(args.sleep)
        except HttpError as e:
            status = getattr(e, "status_code", None) or (e.resp.status if hasattr(e, "resp") else None)
            msg = ""
            try:
                msg = e.error_details if hasattr(e, "error_details") else e.content.decode()
            except Exception:
                pass
            print(f"Failed to add {video_id}: HTTP {status} {msg}", file=sys.stderr)
            failures.append((video_id, f"HTTP {status}"))
        except Exception as e:
            print(f"Failed to add {video_id}: {e}", file=sys.stderr)
            failures.append((video_id, str(e)))

    print(f"\nDone. Successfully added: {added}")
    if failures:
        print(f"Failures: {len(failures)} (see failures.log)")
        with open("failures.log", "w", encoding="utf-8") as f:
            for vid, reason in failures:
                f.write(f"{vid}\t{reason}\n")


if __name__ == "__main__":
    main()
