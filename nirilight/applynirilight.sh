#!/usr/bin/env bash

cp -r ~/.config/nirilight/alacritty ~/.config/

cp -r ~/.config/nirilight/conky ~/.config/

cp -r ~/.config/nirilight/fastfetch ~/.config/

cp -r ~/.config/nirilight/rofi ~/.config/

cp -r ~/.config/nirilight/swaync ~/.config/

cp -r ~/.config/nirilight/swaylock ~/.config/

cp -r ~/.config/nirilight/waybar ~/.config/
cp -r ~/.config/nirilight/hypr ~/.config/

rm -rf ~/walls

cp -r ~/.config/nirilight/walls ~/

rm -rf ~/awalls

cp -r ~/.config/nirilight/awalls ~/


cp -r ~/.config/nirilight/fish ~/.config/

$HOME/.config/waybar/twobars.sh

gsettings set org.gnome.desktop.interface icon-theme 'Zafiro-Nord-Black'

gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-BL-MB-Light'

gsettings set org.gnome.desktop.interface cursor-theme 'Capitaine-Cursors-White'
hyprctl setcursor Capitaine-Cursors-White 17

bash ~/.config/vscode-theme.sh "Nord" "symbols"

$HOME/walls/wallpaperchange2.sh


pkill -9 swaync 2>/dev/null
sleep 0.3
swaync &
     
     



