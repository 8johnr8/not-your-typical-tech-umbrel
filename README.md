# Not Your Typical Tech — Umbrel Community App Store

A community app store for [umbrelOS](https://umbrel.com).

## Apps

| App | Port | What it is |
| --- | --- | --- |
| **Kiwix** (`nytt-kiwix`) | 8907 | Offline Wikipedia & more. A fixed version of the official app: choose your ZIM folder in Settings → Folders, ZIM files in sub-folders are found, it starts with an empty library, and new downloads show up automatically without a restart. |
| **BookOrbit** (`nytt-bookorbit`) | 8909 | Self-hosted library and reader with Kobo/KOReader sync and OPDS. |
| **Minecraft Server** (`nytt-minecraft`) | 8910 (files), 25565 (game) | Minecraft: Java Edition server with a web file manager; server type, version and memory are configurable in Settings. |
| **Minecraft Bedrock Server** (`nytt-minecraft-bedrock`) | 8911 (files), 19132/UDP (game) | Minecraft: Bedrock Edition server (Windows, mobile, consoles) with a web file manager; always runs the newest Bedrock version. |

## Add this store to your Umbrel

1. Open the **App Store** on your Umbrel.
2. Click the **⋯** menu in the top-right corner → **Community App Stores**.
3. Paste `https://github.com/8johnr8/not-your-typical-tech-umbrel` and click **Add**.

## Updates

Apps follow their upstream releases automatically:

1. [Renovate](https://docs.renovatebot.com) watches every image and, once a release is at least 3 days old, commits the new tag (pinned by digest) straight to `main`.
2. The **Sync app versions** workflow then sets `version` and `releaseNotes` in that app's `umbrel-app.yml` to match its main image (mapping in `.github/app-versions.json`).
3. umbrelOS picks up the new version and offers the update in the App Store.

The PostgreSQL major version of BookOrbit's database is never bumped automatically, because it needs a manual data migration.

## App notes

### Kiwix
Put `.zim` files (from [library.kiwix.org](https://library.kiwix.org)) in your **Downloads** folder, or pick another folder under the app's **Settings → Folders**. The library is rescanned every 60 seconds (configurable with `RESCAN_INTERVAL`).

### BookOrbit
On first launch BookOrbit asks for a setup token: use the password Umbrel shows when opening the app. Books go in the **Books** folder of the Files app (or pick another folder in **Settings → Folders**); add `/books` as a library inside BookOrbit.

### Minecraft Server
Connect to `umbrel.local` (port 25565). Opening the app gives you a file manager for the server folder. Installing it means you accept the [Minecraft EULA](https://www.minecraft.net/eula).

### Minecraft Bedrock Server
Add a server with your Umbrel's IP address and port `19132`, or join from the **Friends** tab on your home network (the only way for consoles). The server downloads the newest Bedrock version every time it starts; if players see "outdated server" after a game update, restart the app. Installing it means you accept the [Minecraft EULA](https://www.minecraft.net/eula).
