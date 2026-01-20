#!/usr/bin/env bash
set -e  # stop on error

echo "[*] Stowing dotfiles..."

stow --restow kitty
stow --restow oh-my-posh
stow --restow zsh
stow --restow kde

echo "[*] Done!"

echo "[*] Applying KDE files..."

kquitapp6 kglobalaccel || true
kstart6 kglobalaccel

kquitapp6 plasmashell || true
kstart6 plasmashell

echo "[*] Done!"

