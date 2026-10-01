# Not Your Typical Tech — Umbrel Community App Store

A community app store for [umbrelOS](https://umbrel.com).

## Apps

| App | Port | What it is |
| --- | --- | --- |
| **Kiwix** (`nytt-kiwix`) | 8907 | Offline Wikipedia & more. A fixed version of the official app: choose your ZIM folder in Settings → Folders, ZIM files in sub-folders are found, it starts with an empty library, and new downloads show up automatically without a restart. |
| **Mastodon** (`nytt-mastodon`) | 8908 | Your own fediverse server. Full stack (web, streaming, Sidekiq, PostgreSQL, Redis) with secrets, database and an Owner account set up automatically. |
| **BookOrbit** (`nytt-bookorbit`) | 8909 | Self-hosted library and reader with Kobo/KOReader sync and OPDS. |
| **Minecraft Server** (`nytt-minecraft`) | 8910 (files), 25565 (game) | Minecraft: Java Edition server with a web file manager; server type, version and memory are configurable in Settings. |

## Add this store to your Umbrel

1. Open the **App Store** on your Umbrel.
2. Click the **⋯** menu in the top-right corner → **Community App Stores**.
3. Paste `https://github.com/8johnr8/not-your-typical-tech-umbrel` and click **Add**.

## Updates

Apps follow their upstream releases automatically:

1. [Renovate](https://docs.renovatebot.com) watches every image and, once a release is at least 3 days old, commits the new tag (pinned by digest) straight to `main`.
2. The **Sync app versions** workflow then sets `version` and `releaseNotes` in that app's `umbrel-app.yml` to match its main image (mapping in `.github/app-versions.json`).
3. umbrelOS picks up the new version and offers the update in the App Store.

Major versions of PostgreSQL and Redis are never bumped automatically, because they need a manual data migration.

## App notes

### Kiwix
Put `.zim` files (from [library.kiwix.org](https://library.kiwix.org)) in your **Downloads** folder, or pick another folder under the app's **Settings → Folders**. The library is rescanned every 60 seconds (configurable with `RESCAN_INTERVAL`).

### Mastodon
- Log in with `owner@umbrel.local` and the password Umbrel shows when you open the app.
- By default the server runs at `https://umbrel.local:8908` for your home network only.
- To federate, expose port 8908 through a tunnel (Cloudflare Tunnel, Tailscale Funnel, …) and set `LOCAL_DOMAIN` in **Settings → Environment** **before** you start posting or following. Mastodon cannot change its domain after it has federated.
- Set the `SMTP_*` settings to send e-mails.

### BookOrbit
On first launch BookOrbit asks for a setup token: use the password Umbrel shows when opening the app. Books go in the **Books** folder of the Files app (or pick another folder in **Settings → Folders**); add `/books` as a library inside BookOrbit.

### Minecraft Server
Connect to `umbrel.local` (port 25565). Opening the app gives you a file manager for the server folder. Installing it means you accept the [Minecraft EULA](https://www.minecraft.net/eula).
