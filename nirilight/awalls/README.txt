Animated wallpapers (per theme)
===============================

Works just like the static ~/walls: each theme keeps its OWN animated
wallpapers in its source folder:

    ~/.config/niricold/awalls/
    ~/.config/nirilight/awalls/
    ~/.config/niriwarm/awalls/

Applying a theme (apply<theme>.sh) does:  rm -rf ~/awalls ; cp -r <theme>/awalls ~/
so ~/awalls always holds the CURRENT theme's videos.

To add/remove a wallpaper for a theme, edit that theme's source folder above,
then re-apply the theme. (Putting a file only in ~/awalls is temporary — the
next theme switch overwrites it.)

Supported: .mp4 .webm .mkv .mov .gif .m4v .avi
Open the picker with F9 or the film icon (󰕧) on Waybar.
Picking one stops the current wallpaper and starts the new one with mpvpaper.

Files kept in every awalls folder:
  anim-wallpaper-picker.py   -> the picker (GTK + ffmpeg + mpvpaper)
  anim-wallpaper-restore.sh  -> re-applies the last clip on login
