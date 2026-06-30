Animated wallpapers
===================

Drop your animated wallpapers in this folder (~/awalls):
  .mp4  .webm  .mkv  .mov  .gif  .m4v  .avi

Open the picker with the F9 key, or the film icon (󰕧) on Waybar.
Selecting one stops the current wallpaper and starts the new one with mpvpaper.

Requirements: mpvpaper, mpv, ffmpeg, python3-gobject (gtk3).
Per-theme copies live in ~/.config/<theme>/awalls and are deployed by the
apply<theme>.sh scripts (rm -rf ~/awalls ; cp -r .../awalls ~/).
