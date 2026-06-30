#!/usr/bin/env bash
# Re-apply the last animated wallpaper on login (if one was set).
# Runs after wallpaperchange2.sh, so it overrides the random static wallpaper
# only when an animated one was previously selected.

STATE="$HOME/.cache/anim-wallpaper-current"
MPV_OPTS="no-audio --loop-file=inf --hwdec=auto --panscan=1.0"

[ -f "$STATE" ] || exit 0
WP="$(cat "$STATE")"
[ -f "$WP" ] || exit 0   # file gone (e.g. theme switched) -> keep static wallpaper

pkill -x mpvpaper 2>/dev/null
pkill -x swaybg   2>/dev/null
sleep 0.3
setsid mpvpaper -o "$MPV_OPTS" '*' "$WP" >/dev/null 2>&1 &
