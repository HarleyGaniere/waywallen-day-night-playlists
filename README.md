# Waywallen Day/Night Playlists

Switches [Waywallen](https://github.com/waywallen/waywallen) playlists with your light/dark theme: one playlist for day (light theme), another for night (dark theme).

It works on any Linux distribution and desktop environment that tells apps whether the theme is light or dark through the standard desktop portal. KDE Plasma and GNOME do this out of the box, whether you switch by hand or automatically at sunset.

* A theme change while the screen is locked is applied a few seconds after you unlock, once your displays are back.
* The burst of light/dark announcements some desktops send while applying a theme is ignored; it switches once, after the theme settles.
* Activating a playlist also makes it Waywallen's auto-attach playlist, so the right one comes back after a restart or on a new display.

## Requirements

| Requirement | Why | Package |
| --- | --- | --- |
| [Waywallen](https://github.com/waywallen/waywallen) | The wallpaper daemon this controls | See its README |
| Python 3.8+ | Runs the script (standard library only) | `python3` / `python` |
| `gdbus` | Talks to D-Bus | Fedora, Arch: `glib2` · Debian, Ubuntu: `libglib2.0-bin` · openSUSE: `glib2-tools` |
| `xdg-desktop-portal` with a backend that reports the color scheme | Tells the script whether the theme is light or dark | See [Light/Dark Indicator](#lightdark-indicator) |

## Install

```bash
git clone https://github.com/HarleyGaniere/waywallen-day-night-playlists.git
cd waywallen-day-night-playlists
./install.sh
```

`install.sh` copies the script to `/usr/local/bin` and a systemd user service to `~/.config/systemd/user`. Create a day playlist and a night playlist in Waywallen, put their names in the service file, then enable it:

```bash
nano ~/.config/systemd/user/waywallen-day-night-playlists.service
systemctl --user daemon-reload
systemctl --user enable --now waywallen-day-night-playlists.service
```

## Usage

```bash
waywallen-day-night-playlists list                              # playlists, their ids, and the current theme
waywallen-day-night-playlists activate "Night"                  # activate one now
waywallen-day-night-playlists watch --light "Day" --dark "Night"
```

Logs: `journalctl --user -u waywallen-day-night-playlists -f`

## Light/Dark Indicator

The script reads the `org.freedesktop.appearance` `color-scheme` setting from the desktop portal: `1` means dark, `0` (no preference) or `2` means light. Check what your system reports:

```bash
gdbus call --session --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.portal.Settings.ReadOne org.freedesktop.appearance color-scheme
```

Switch your theme and run it again. If the number changes between `1` and `0`/`2`, everything is in place. If the command fails or the number never changes, set up your desktop below.

### KDE Plasma

Works out of the box with `xdg-desktop-portal-kde`. Any color scheme counts as dark when its window background is dark. For automatic switching at sunset, turn on automatic light/dark switching under System Settings → Colors & Themes → Global Theme; it follows the Night Light schedule.

### GNOME

Works out of the box with `xdg-desktop-portal-gnome`. Dark Style in Settings → Appearance is the indicator. GNOME has no built-in sunset switch; the [Night Theme Switcher](https://extensions.gnome.org/extension/2236/night-theme-switcher/) extension adds one.

### Other Desktops and Window Managers

Cinnamon, MATE, Xfce, Budgie, Sway, Hyprland, niri, river and others need a portal backend that reports the color scheme:

* **xdg-desktop-portal-gtk** (Fedora, Arch: `xdg-desktop-portal-gtk` · Debian, Ubuntu: `xdg-desktop-portal-gtk`) reports GNOME's dark-style setting, which you can flip from any desktop:

  ```bash
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark   # dark
  gsettings set org.gnome.desktop.interface color-scheme default       # light
  ```

  Bind those to keys, or run them from your own scripts or a timer.
* **[darkman](https://gitlab.com/WhyNotHugo/darkman)** implements the portal itself and switches light/dark at sunrise and sunset for your location. Run `darkman toggle` to switch by hand.

On wlroots-based compositors, make sure your portal config (`~/.config/xdg-desktop-portal/portals.conf` or your compositor's `*-portals.conf`) routes the Settings interface to the backend you installed, for example:

```ini
[preferred]
default=wlr;gtk
org.freedesktop.impl.portal.Settings=darkman
```

Then restart the portal: `systemctl --user restart xdg-desktop-portal`.

### Screen Lock Detection

Deferring changes until unlock uses the `org.freedesktop.ScreenSaver` D-Bus interface, which KDE Plasma and GNOME provide. Where it isn't available, the script still works; it simply applies changes immediately.

## Without systemd

On distributions without systemd user services (Void, Gentoo with OpenRC, Artix, and others), start the watcher from your desktop's autostart instead. Create `~/.config/autostart/waywallen-day-night-playlists.desktop`:

```ini
[Desktop Entry]
Type=Application
Name=Waywallen Day/Night Playlists
Exec=/usr/local/bin/waywallen-day-night-playlists watch --light "Day" --dark "Night"
X-GNOME-Autostart-enabled=true
```

Or add the `watch` command to your compositor's startup (for example `exec` in Sway or `exec-once` in Hyprland). It waits for Waywallen if it starts first.

## How It Works

The script finds Waywallen's control port on D-Bus (`org.waywallen.waywallen.Daemon`), then talks to the daemon over its WebSocket control protocol, the same one the Waywallen app uses. It watches the portal's `SettingChanged` signal for color-scheme changes and the screensaver's `ActiveChanged` signal for lock/unlock.
