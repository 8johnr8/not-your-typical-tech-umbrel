#!/usr/bin/env python3
"""Keep each app's version in umbrel-app.yml in sync with its main image tag.

Umbrel only offers an update when `version` in umbrel-app.yml changes, while
Renovate only bumps image tags in docker-compose.yml. This script closes the
gap. It edits the manifest as text so the rest of the file is left untouched.
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
SOURCES = json.loads((ROOT / ".github" / "app-versions.json").read_text())


def image_tag(compose: str, image: str) -> str | None:
    m = re.search(rf"image:\s*{re.escape(image)}:([^@\s]+)", compose)
    return m.group(1) if m else None


def main() -> int:
    changed = []
    for app, image in SOURCES.items():
        if app.startswith("_"):
            continue
        app_dir = ROOT / app
        manifest_path = app_dir / "umbrel-app.yml"
        compose_path = app_dir / "docker-compose.yml"
        if not manifest_path.exists() or not compose_path.exists():
            print(f"skip {app}: files not found")
            continue

        tag = image_tag(compose_path.read_text(), image)
        if not tag:
            print(f"skip {app}: image {image} not found in docker-compose.yml")
            continue
        new_version = tag[1:] if re.match(r"^v\d", tag) else tag

        manifest = manifest_path.read_text()
        m = re.search(r'^version:\s*"?([^"\n]+)"?\s*$', manifest, re.M)
        if not m:
            print(f"skip {app}: no version field")
            continue
        old_version = m.group(1)
        if old_version == new_version:
            continue

        manifest = manifest[: m.start()] + f'version: "{new_version}"' + manifest[m.end():]

        repo = re.search(r"^repo:\s*(\S+)\s*$", manifest, re.M)
        notes = f"Updated to version {new_version}."
        if repo:
            notes += f" See the upstream release notes at {repo.group(1)}/releases"
        # Replace the releaseNotes block (key plus its indented lines).
        manifest, n = re.subn(
            r"^releaseNotes:.*\n(?:[ \t]+.*\n|\n(?=[ \t]))*",
            f"releaseNotes: >-\n  {notes}\n",
            manifest,
            count=1,
            flags=re.M,
        )
        if n == 0:
            manifest = manifest.rstrip("\n") + f"\nreleaseNotes: >-\n  {notes}\n"

        manifest_path.write_text(manifest)
        changed.append(f"{app} {old_version} -> {new_version}")
        print(f"{app}: {old_version} -> {new_version}")

    if not changed:
        print("All app versions already match their images.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
