#!/usr/bin/env bash

cp -r ~/.config/niriwarm/alacritty ~/.config/

cp -r ~/.config/niriwarm/conky ~/.config/

cp -r ~/.config/niriwarm/fastfetch ~/.config/

cp -r ~/.config/niriwarm/rofi ~/.config/

cp -r ~/.config/niriwarm/swaync ~/.config/

cp -r ~/.config/niriwarm/swaylock ~/.config/

cp -r ~/.config/niriwarm/waybar ~/.config/
cp -r ~/.config/niriwarm/hypr ~/.config/

rm -rf ~/walls

cp -r ~/.config/niriwarm/walls ~/

rm -rf ~/awalls

cp -r ~/.config/niriwarm/awalls ~/


cp -r ~/.config/niriwarm/fish ~/.config/

$HOME/.config/waybar/twobars.sh

gsettings set org.gnome.desktop.interface icon-theme 'Gruvbox-Plus-Dark'

gsettings set org.gnome.desktop.interface gtk-theme 'Gruvbox-BL-MB-Dark-Medium'

gsettings set org.gnome.desktop.interface cursor-theme 'Capitaine-Cursors-Gruvbox'
hyprctl setcursor Capitaine-Cursors-Gruvbox 17

bash ~/.config/vscode-theme.sh "Gruvbox Dark Medium" "gruvbox-material-icon-theme"

$HOME/walls/wallpaperchange2.sh


pkill -9 swaync 2>/dev/null
sleep 0.3
swaync &
     



