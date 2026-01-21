#!/usr/bin/env bash
set -euo pipefail

DOTFILES=(
  kitty
  oh-my-posh
  zsh
  kde
)

echo "[*] Stowing dotfiles..."

for dir in "${DOTFILES[@]}"; do
  echo "    Stowing $dir"
  stow --restow "$dir"
done

echo "[*] Done!"
