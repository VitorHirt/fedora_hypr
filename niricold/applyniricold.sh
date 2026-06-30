#!/usr/bin/env bash

cp -r ~/.config/niricold/alacritty ~/.config/

cp -r ~/.config/niricold/conky ~/.config/

cp -r ~/.config/niricold/fastfetch ~/.config/

cp -r ~/.config/niricold/rofi ~/.config/

cp -r ~/.config/niricold/swaync ~/.config/

cp -r ~/.config/niricold/swaylock ~/.config/

cp -r ~/.config/niricold/waybar ~/.config/

cp -r ~/.config/niricold/hypr ~/.config/

rm -rf ~/walls

cp -r ~/.config/niricold/walls ~/


cp -r ~/.config/niricold/fish ~/.config/

cp -r ~/.config/niricold/hypr ~/.config/

$HOME/.config/waybar/twobars.sh

gsettings set org.gnome.desktop.interface icon-theme 'Zafiro-Nord-Black-Blue'

gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-BL-MB-Dark'

gsettings set org.gnome.desktop.interface cursor-theme 'Capitaine-Cursors-Nord'
hyprctl setcursor Capitaine-Cursors-Nord 17

bash ~/.config/vscode-theme.sh "Catppuccin Mocha" "charmed-icons"

$HOME/walls/wallpaperchange2.sh

pkill -9 swaync 2>/dev/null
sleep 0.3
swaync &

     
     
     



