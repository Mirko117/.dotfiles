#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
    printf 'Run this script as normal user, not root.\n' >&2
    exit 1
fi

if [[ ! -f /etc/fedora-release ]] || ! command -v dnf > /dev/null 2>&1; then
    printf 'This installer only supports Fedora using dnf.\n' >&2
    exit 1
fi

DOTFILES_DIR="$HOME/.dotfiles"

backup_if_unmanaged() {
    local target="$1"
    local backup

    if [[ -e "$target" && ! -L "$target" ]]; then
        backup="${target}.backup.$(date +%Y%m%d-%H%M%S)"
        printf 'Backing up %s to %s\n' "$target" "$backup"
        mv -- "$target" "$backup"
    fi
}

stow_configs() {
    printf '[*] Stowing dotfiles...\n'

    backup_if_unmanaged "$HOME/.zshrc"
    backup_if_unmanaged "$HOME/.poshthemes"
    backup_if_unmanaged "$HOME/.config/kitty"

    mkdir -p "$HOME/.config"
    cd "$DOTFILES_DIR"
    stow --restow zsh kitty oh-my-posh
}

check_command () {
    if command -v "$1" > /dev/null 2>&1; then
        printf '[+] Ok: %s\n' "$1"
    else
        printf '[-] Missing: %s\n' "$1" >&2
        return 1
    fi
}

sanity_check() {
    printf '[*] Running sanity checks\n'
    check_command git
    check_command stow
    check_command kitty
    check_command python3
    check_command uv
    check_command oh-my-posh
    check_command konsave
    check_command code
    check_command docker
}

install_packages() {
    printf '[*] Installing packages...\n'

    sudo dnf install -y \
        curl \
        stow \
        git \
        zsh \
        kitty \
        python3 \
        python3-pip \
        python3-uv
}


setup_zsh() {
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local zsh_path

    printf '[*] Setting up Zsh...\n'

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    install_zsh_plugin() {
        local repository="$1"
        local name="$2"
        local destination="$zsh_custom/plugins/$name"

        if [[ ! -d "$destination" ]]; then
            git clone "$repository" "$destination" 
        fi
    }

    install_zsh_plugin https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
    install_zsh_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git zsh-syntax-highlighting

    zsh_path="$(command -v zsh)"
    if [[ "${SHELL:-}" != "$zsh_path" ]]; then
        chsh -s "$zsh_path"
    fi
}

setup_tools() {
    printf '[*] Setting up other tools...\n'

    if ! command -v oh-my-posh > /dev/null 2>&1; then
        curl -s https://ohmyposh.dev/install.sh | bash -s
    fi

    if ! command -v konsave > /dev/null 2>&1; then
        uv tool install konsave
    fi

    if ! command -v code > /dev/null 2>&1; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" \
            | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
        sudo dnf install -y code
    fi
}

setup_docker() {
    printf '[*] Setting up Docker...\n'

    if ! command -v docker > /dev/null 2>&1; then
        sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    fi

    sudo systemctl enable --now docker

    if ! id -nG "$USER" | grep -qw docker; then
        sudo usermod -aG docker "$USER"
        printf '[+] Docker group added; log out and back in before using Docker without sudo.\n'
    fi
}

install_packages
setup_zsh
setup_tools
setup_docker
stow_configs
sanity_check

printf '[*] Setup completed! Reboot the machine to use the new shell and Docker group.\n'
