# SETUP

The setup script targets Fedora.

It installs:
- packages (stow, git, zsh, kitty, python3, python3-pip, python3-uv)
- Zsh
- Zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting)
- Oh My Posh
- Konsave
- VS Code
- Docker

then it Stows the Zsh, Kitty and Oh My Posh configurations.

Run the installer as your normal user:

```bash
git clone <repository-url> ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer backs up unmanaged files such as `~/.zshrc` before Stow creates
links. Log out and back in (or reboot) after the first run so the new login shell andDocker group membership take effect.

## Konsave

Konsave is a tool for managing and sharing KDE desktop configurations. Profile file is not included in this repository, but you can export your own configuration with `konsave -e <profile-name>` and import it on another machine with `konsave -i <profile-name>.knsv` and `konsave -a <profile-name>`. 

Read more about Konsave at [Konsave GitHub](https://github.com/Prayag2/konsave)

## Other stuff

[RTL8821CE Driver](docs/rtl8821ce-driver.md)

[Booting Fedora Directly with rEFInd](docs/refind-direct-boot.md)