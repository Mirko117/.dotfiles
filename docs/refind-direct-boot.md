# Booting Fedora Directly with rEFInd (No GRUB, Separate /boot, Btrfs)


This guide documents how to fix the situation where:

- Fedora is installed on a second SSD
- Fedora uses:
  - separate `/boot` (ext4)
  - separate `/boot/efi` (ESP)
  - Btrfs root with subvolumes
- rEFInd can only boot Fedora via: 
    - `rEFInd → Fedora GRUB → Fedora`
- Direct kernel boot fails with:
    - `initrd-switch-root.service failed`
    - `The root account is locked`


## Root Cause

1. Fedora stores kernels in `/boot`, which is a separate partition.
2. rEFInd cannot see `/boot` unless it is on the ESP and does not read GRUB configs.
3. Fedora uses Btrfs subvolumes, so the kernel must be told:
    - which disk is `/`
    - which subvolume to mount
4. rEFInd only reads `refind_linux.conf` from the same filesystem as the kernel.


## Example Disk Layout
```
sda1 vfat → /boot/efi (ESP)
sda2 ext4 → /boot (Fedora kernels normally live here)
sda3 btrfs → / (subvol=root)
```

## Final Strategy

Move Fedora kernels to the ESP and tell rEFInd exactly how to boot them.


## Step-by-Step Fix

### 1. Confirm Fedora’s root subvolume

Boot Fedora via GRUB, then run:

```bash
findmnt /
```

Example output:
```bash
/dev/sda3[/root]
```

Subvolume name = `root`.


### 2. Get Fedora’s known-good kernel arguments

```bash
cat /proc/cmdline
```

Example:
```bash
root=UUID=63983fdb-69f5-4de0-932a-b27e3894da53 ro rootflags=subvol=root rhgb quiet
```

Copy this line exactly, do not guess.

### 3. Copy Fedora kernels to the ESP

```bash
sudo mkdir -p /boot/efi/EFI/fedora-kernels
sudo cp /boot/vmlinuz-* /boot/efi/EFI/fedora-kernels/
sudo cp /boot/initramfs-* /boot/efi/EFI/fedora-kernels/
```

### 4. Create `refind_linux.conf` next to the kernel

Create the file in the ESP kernel directory:
```bash
sudo nano /boot/efi/EFI/fedora-kernels/refind_linux.conf
```

Paste the following (adjust with info from step 2 and subvolume from step 1):
```bash
"Fedora Linux"  "root=UUID=63983fdb-69f5-4de0-932a-b27e3894da53 ro rootflags=subvol=root rhgb quiet"
```

Save and exit.


### 5. Reboot and test

Fedora should now boot directly, without GRUB, and without emergency mode.


## Optional: Survive Kernel Updates (not tested)

Create a kernel install hook:
```bash
sudo nano /etc/kernel/postinst.d/refind-copy
```

Paste:
```bash
#!/bin/sh
cp /boot/vmlinuz-* /boot/efi/EFI/fedora-kernels/
cp /boot/initramfs-* /boot/efi/EFI/fedora-kernels/
```

Enable:
```bash
sudo chmod +x /etc/kernel/postinst.d/refind-copy
```

Now every kernel update keeps rEFInd happy.
