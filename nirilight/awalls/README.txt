Animated wallpapers
===================

Drop your animated wallpapers in this folder (~/awalls):
  .mp4  .webm  .mkv  .mov  .gif  .m4v  .avi

Open the picker with the F9 key, or the film icon (󰕧) on Waybar.
It is a GTK picker with the SAME look as the static ~/walls/wallpaper-picker.py
(big circular thumbnails, horizontal scroll). The thumbnails are extracted from
the videos with ffmpeg; selecting one stops the current wallpaper and starts the
new one with mpvpaper.

Files:
  ~/awalls/anim-wallpaper-picker.py   -> the picker (GTK + ffmpeg + mpvpaper)
  ~/awalls/anim-wallpaper-restore.sh  -> re-applies the last clip on login

Requirements: mpvpaper, mpv, ffmpeg, python3-gobject (gtk3).
Per-theme copies live in ~/.config/<theme>/awalls and are deployed by the
apply<theme>.sh scripts.
