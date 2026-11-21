#!/usr/bin/env bash
# Install the script to /usr/local/bin and the login service for this user.
set -euo pipefail
cd "$(dirname "$0")"

sudo install -m 755 waywallen-theme-playlists /usr/local/bin/waywallen-theme-playlists
echo "Installed /usr/local/bin/waywallen-theme-playlists"

mkdir -p ~/.config/systemd/user
if [[ ! -f ~/.config/systemd/user/waywallen-theme-playlists.service ]]; then
    cp systemd/waywallen-theme-playlists.service ~/.config/systemd/user/
    echo "Copied the service. Edit the playlist names in"
    echo "  ~/.config/systemd/user/waywallen-theme-playlists.service"
    echo "then run:"
    echo "  systemctl --user daemon-reload && systemctl --user enable --now waywallen-theme-playlists.service"
else
    echo "Kept your existing ~/.config/systemd/user/waywallen-theme-playlists.service"
fi
