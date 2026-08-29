# rtl8821ce

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
