#!/usr/bin/env bash
# Install the script to /usr/local/bin and the login service for this user.
# Also migrates from the old name, waywallen-theme-playlists.
set -euo pipefail
cd "$(dirname "$0")"

NAME=waywallen-day-night-playlists
OLD=waywallen-theme-playlists
UNITS=~/.config/systemd/user

sudo install -m 755 "$NAME" "/usr/local/bin/$NAME"
echo "Installed /usr/local/bin/$NAME"

mkdir -p "$UNITS"
if [[ -f "$UNITS/$NAME.service" ]]; then
    echo "Kept your existing $UNITS/$NAME.service"
elif [[ -f "$UNITS/$OLD.service" ]]; then
    # Carry over the playlist names from the old service
    systemctl --user disable --now "$OLD.service" 2>/dev/null || true
    sed "s/$OLD/$NAME/g; s/^Description=.*/$(grep '^Description=' "systemd/$NAME.service")/" \
        "$UNITS/$OLD.service" > "$UNITS/$NAME.service"
    rm -f "$UNITS/$OLD.service"
    sudo rm -f "/usr/local/bin/$OLD"
    systemctl --user daemon-reload
    systemctl --user enable --now "$NAME.service"
    echo "Migrated $OLD.service to $NAME.service (same playlists) and started it"
else
    cp "systemd/$NAME.service" "$UNITS/"
    echo "Copied the service. Edit the playlist names in"
    echo "  $UNITS/$NAME.service"
    echo "then run:"
    echo "  systemctl --user daemon-reload && systemctl --user enable --now $NAME.service"
fi
