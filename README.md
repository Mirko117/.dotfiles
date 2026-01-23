# SETUP

## zsh
```bash
sudo apt install zsh -y
```

Make it default
```bash
chsh -s $(which zsh)
```

## Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

```

### Install Plugins


zsh-autosuggestions
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

```

zsh-syntax-highlighting
```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

```

### Enable Plugins

Edit `~/.zshrc` and find the `plugins=(...)` line. Add them:
```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

```bash
source ~/.zshrc
```

## Oh My Posh

```bash
curl -s https://ohmyposh.dev/install.sh | bash -s
```

## ERRORS

##### /home/[user]/.zshrc:3: command not found: oh-my-posh

Check if it’s installed
```bash
~/.local/bin/oh-my-posh --version
```

Add this to your `~/.zshrc` before the `eval "$(oh-my-posh ...)` line:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## DRIVERS


### rtl8821ce

Guide to install driver for rtl8821ce is in <a href="https://github.com/tomaspinho/rtl8821ce">this</a> repo. Read it, install required packages, clone the repo and follow next steps:

Blocklist built in drivers. At the botton of `/etc/modprobe.d/blacklist.conf` add:

```bash
blacklist rtw88_8821ce
blacklist rtw88_core
blacklist rtw88_pci
```

Save it and then run:
```bash
sudo update-initramfs -u
```
and reboot machine. After rebooting it, go to the cloned repo and run next two commands:
```bash
sudo ./dkms-install.sh
sudo modprobe 8821ce
```


## Other stuff

[Booting Fedora Directly with rEFInd](docs/refind-direct-boot.md)