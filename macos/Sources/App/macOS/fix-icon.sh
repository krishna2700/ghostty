#!/bin/bash
# This script is bundled inside Blackbox Terminal
# It fixes the dock/finder icon automatically on first launch

APP="/Applications/Blackbox Terminal.app"
ICON="$APP/Contents/Resources/Blackbox.icns"
MARKER="$HOME/.blackbox_icon_fixed"

# Only run once
if [ -f "$MARKER" ]; then
    exit 0
fi

# Install fileicon if brew is available
if which brew &>/dev/null && ! which fileicon &>/dev/null; then
    brew install fileicon -q 2>/dev/null
fi

# Set icon permanently
if which fileicon &>/dev/null; then
    fileicon set "$APP" "$ICON" 2>/dev/null
fi

# Clear icon cache
sudo rm -rf /Library/Caches/com.apple.iconservices.store 2>/dev/null || true
find /private/var/folders -name "com.apple.dock.iconcache" -delete 2>/dev/null || true

# Restart Dock
killall Dock 2>/dev/null || true

# Mark as done so it never runs again
touch "$MARKER"
