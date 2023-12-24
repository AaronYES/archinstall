#!/bin/bash

# Modify mkinitcpio
sed -i 's/^MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf
sed -i 's/\(^HOOKS=.*\)filesystems\(.*$\)/\1encrypt filesystems\2/' /etc/mkinitcpio.conf
mkinitcpio -p linux

# Set timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohchwclock --systohc


sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo "arch" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.0.1 arch.localdomain arch" >> /etc/hosts

# Add user
read -p "Enter username: " username
useradd -m -g users -G wheel -s /bin/bash $username
echo "$username ALL=(ALL) ALL" >> /etc/sudoers.d/$username

# Set password
read -rsp "Enter $username password: " userpassword
echo -e "\n"
echo "$username:$userpassword" | chpasswd
echo -e "\n"
read -rsp "Enter root password: " rootpassword
echo -e "\n"
echo "root:$rootpassword" | chpasswd

# Enable the service
systemctl enable NetworkManager --now
systemctl enable sshd --now

# Systemd Boot
bootctl --path=/boot install
echo "timeout 3" >> /boot/loader/loader.conf
echo "default arch" >> /boot/loader/loader.conf

disk_uuid=$(blkid -s UUID -o value "/dev/${disk}p2")
mapper_uuid=$(blkid -s UUID -o value "/dev/mapper/root")

cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=UUID=$disk_uuid:root root=UUID=$mapper_uuid rootflags=subvol=@ rw
EOF

cp /boot/loader/entries/arch.conf /boot/loader/entries/arch-fallback.conf
sed -i 's/initrd \/initramfs-linux.img/initrd \/initramfs-linux-fallback.img/' /boot/loader/entries/arch-fallback.conf

exit
umount -R /mnt

echo "Done! You can reboot now."
