#!/usr/bin/env bash
# Sets the VS Code (Flatpak) color + icon theme by patching settings.json.
# VS Code watches the file and applies the theme live, so no restart is needed.
#
# Usage: vscode-theme.sh "<colorTheme>" "<iconTheme>"

SETTINGS="$HOME/.var/app/com.visualstudio.code/config/Code/User/settings.json"

# Nothing to do if VS Code config isn't present yet.
[ -f "$SETTINGS" ] || exit 0

python3 - "$SETTINGS" "$1" "$2" <<'PY'
import json, sys

path, color, icon = sys.argv[1], sys.argv[2], sys.argv[3]

try:
    with open(path) as f:
        data = json.load(f)
except Exception:
    data = {}

data["workbench.colorTheme"] = color
data["workbench.iconTheme"] = icon

with open(path, "w") as f:
    json.dump(data, f, indent=4)
    f.write("\n")
PY
