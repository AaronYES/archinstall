#!/bin/bash

read -p "Enter the disk you want to install: " disk

# Format the disk
wipefs --all "/dev/$disk"

# Create partitions
gdisk_command() {
  echo -e "n\n\n\n+$1\n$2\nw\ny\n" | gdisk "/dev/$disk"
}
gdisk_command "300M" "EF00"
gdisk_command "" "8300"

clear

# Create encryption
read -p "Press 'YES' to continue with formatting: " response
if [ "$response" = "YES" ]; then
  read -rsp "Enter passphrase: " passphrase
  echo -e "\n"
  read -rsp "Verify passphrase: " verify_passphrase
  echo -e "\n"

# Verify password consistency
  if [ "$passphrase" = "$verify_passphrase" ]; then
    echo "$passphrase" | cryptsetup --cipher aes-xts-plain64 --hash sha512 --use-random --verify-passphrase luksFormat "/dev/${disk}p2"

    # Open partition
    echo -n "$passphrase" | cryptsetup luksOpen "/dev/${disk}p2" root

  else
    echo "Error: Passphrases do not match."
  fi
else
  echo "Aborted."
fi

# Format partitions
mkfs.fat -F32 "/dev/${disk}p1"
mkfs.btrfs /dev/mapper/root

# Create sub-volumes
mount /dev/mapper/root /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
cd
umount /mnt
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@ /dev/mapper/root /mnt
mkdir /mnt/{boot,home}
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@home /dev/mapper/root /mnt/home/
mount /dev/nvme0n1p1 /mnt/boot

# Install base packages
pacstrap /mnt base base-devel linux linux-firmware btrfs-progs networkmanager openssh vim sudo zsh zsh-completions git

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

clear

echo "👇 Please execute the following command!"
echo "curl -fsSL https://raw.githubusercontent.com/AaronYES/archinstall/main/scripts/install-2.sh | bash"
arch-chroot /mnt
