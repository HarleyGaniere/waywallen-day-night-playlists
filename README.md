# Waywallen Theme Playlists

Switches [Waywallen](https://github.com/waywallen/waywallen) playlists with your light/dark theme: one playlist for light, another for dark.

The theme is read from the desktop portal's `color-scheme` setting, so it follows KDE Plasma (and other desktops) whether you switch by hand or automatically at sunset. It talks to the Waywallen daemon over its control socket and needs only Python 3 and `gdbus`.

## Install

```bash
./install.sh
```

Then put your playlist names in `~/.config/systemd/user/waywallen-theme-playlists.service` and enable it:

```bash
systemctl --user daemon-reload
systemctl --user enable --now waywallen-theme-playlists.service
```

## Usage

```bash
waywallen-theme-playlists list                              # playlists and their ids
waywallen-theme-playlists activate "Night"                  # activate one now
waywallen-theme-playlists watch --light "Day" --dark "Night"
```

Activating a playlist also makes it Waywallen's auto-attach playlist, so the right one comes back after a restart or on a new display.

Logs: `journalctl --user -u waywallen-theme-playlists -f`
