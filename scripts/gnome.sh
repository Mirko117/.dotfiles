#!/usr/bin/env bash
set -e  # stop on error

echo "[*] Restoring GNOME settings..."
stow gnome
dconf load /org/gnome/ < ~/.dotfiles/gnome/gnome-settings.ini

echo "[*] Done!"
