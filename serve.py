#!/usr/bin/env python3
"""Local static server for the basketball free-throw game (fully offline assets)."""

from __future__ import annotations

import mimetypes
import socket
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PORT = 8766


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()

    def log_message(self, fmt: str, *args):
        print("[%s] %s" % (self.log_date_time_string(), fmt % args), flush=True)


def main() -> None:
    mimetypes.add_type("application/javascript", ".js")
    mimetypes.add_type("application/json", ".json")
    mimetypes.add_type("image/png", ".png")
    mimetypes.add_type("image/jpeg", ".jpg")
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)

    lan = "unknown"
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        lan = s.getsockname()[0]
        s.close()
    except OSError:
        pass

    print(f"Local  → http://127.0.0.1:{PORT}/", flush=True)
    print(f"Phones → http://{lan}:{PORT}/  (same Wi‑Fi)", flush=True)
    print(f"Root   → {ROOT}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
