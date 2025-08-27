"""
Copy Brave's Bookmarks Bar into Chrome's Bookmarks Bar on macOS.

- Only replaces the 'children' of Chrome's bookmark bar, preserving the bar's
  root id/name and other roots ('Other bookmarks', 'Mobile bookmarks').
- Default profile is 'Default', but you can target any profile.

Usage examples:
  python3 copy_brave_bar_to_chrome.py
  python3 copy_brave_bar_to_chrome.py --dry-run
  python3 copy_brave_bar_to_chrome.py --brave-profile "Profile 1" --chrome-profile "Default" --force
"""

import argparse
import json
import os
import sys
import subprocess


def default_paths():
    home = os.path.expanduser("~")
    return {
        "brave_dir": os.path.join(
            home, "Library", "Application Support", "BraveSoftware", "Brave-Browser"
        ),
        "chrome_dir": os.path.join(
            home, "Library", "Application Support", "Google", "Chrome"
        ),
    }


def path_for_bookmarks(user_data_dir: str, profile: str) -> str:
    return os.path.join(user_data_dir, profile, "Bookmarks")


def load_json(path: str):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_json(path: str, data: dict):
    # Write compact JSON (Chrome is fine with this)
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")
    os.replace(tmp, path)


def count_nodes(node: dict) -> int:
    """Recursively count total bookmark/folder nodes under a bar node."""
    if not node:
        return 0
    total = 1
    for child in node.get("children", []) or []:
        total += count_nodes(child)
    return total


def app_running(process_name: str) -> bool:
    try:
        result = subprocess.run(
            ["pgrep", "-x", process_name],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return result.returncode == 0
    except Exception:
        return False  # if pgrep isn't available, don't block


def main():
    paths = default_paths()
    ap = argparse.ArgumentParser(
        description="Overwrite Chrome's Bookmarks Bar with Brave's Bookmarks Bar on macOS."
    )
    ap.add_argument(
        "--brave-dir", default=paths["brave_dir"], help="Brave User Data dir"
    )
    ap.add_argument(
        "--chrome-dir", default=paths["chrome_dir"], help="Chrome User Data dir"
    )
    ap.add_argument(
        "--brave-profile",
        default="Default",
        help="Brave profile name (e.g., 'Default', 'Profile 1')",
    )
    ap.add_argument(
        "--chrome-profile",
        default="Default",
        help="Chrome profile name (e.g., 'Default', 'Profile 1')",
    )
    ap.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would change, but don't modify anything",
    )
    ap.add_argument(
        "--force", action="store_true", help="Do not prompt for confirmation"
    )
    args = ap.parse_args()

    brave_path = path_for_bookmarks(args.brave_dir, args.brave_profile)
    chrome_path = path_for_bookmarks(args.chrome_dir, args.chrome_profile)

    # Basic checks
    if not os.path.exists(brave_path):
        print(f"ERROR: Brave bookmarks file not found: {brave_path}", file=sys.stderr)
        sys.exit(1)
    if not os.path.exists(chrome_path):
        print(f"ERROR: Chrome bookmarks file not found: {chrome_path}", file=sys.stderr)
        sys.exit(1)

    # Warn if apps are running (best-effort)
    brave_running = app_running("Brave Browser")
    chrome_running = app_running("Google Chrome")

    if brave_running:
        print(
            "Note: Brave is running. We'll read its bookmarks, but very recent changes may not be flushed yet."
        )

    if chrome_running and not args.force:
        print(
            "ERROR: Chrome is running. Quit Chrome or re-run with --force (Chrome may overwrite our edits on exit)."
        )
        sys.exit(2)

    brave_data = load_json(brave_path)
    chrome_data = load_json(chrome_path)

    # Validate structures
    try:
        brave_bar = brave_data["roots"]["bookmark_bar"]
        chrome_bar = chrome_data["roots"]["bookmark_bar"]
    except KeyError:
        print(
            "ERROR: Could not locate 'roots.bookmark_bar' in one of the files.",
            file=sys.stderr,
        )
        sys.exit(3)

    brave_count = count_nodes(brave_bar) - 1  # exclude root itself
    chrome_count = count_nodes(chrome_bar) - 1

    print(f"Brave bar items:  {brave_count}")
    print(f"Chrome bar items: {chrome_count}")

    if args.dry_run:
        print("Dry run: no changes will be made.")
        return

    # Overwrite just the bar children (safer: keep Chrome bar root id/name and other roots)
    chrome_data["roots"]["bookmark_bar"]["children"] = brave_bar.get("children", [])

    # Optional: keep bar visibility flag if present
    if "visible" in chrome_bar:
        chrome_data["roots"]["bookmark_bar"]["visible"] = chrome_bar["visible"]

    # Save
    save_json(chrome_path, chrome_data)
    print("Success: Chrome Bookmarks Bar has been replaced with Brave's.")
    print(
        "Note: Chrome may recalculate the internal checksum on next launch; that's expected."
    )


if __name__ == "__main__":
    main()
