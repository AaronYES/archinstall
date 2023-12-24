# /etc/pacman.conf
sudo sed -i '/^\[options\]/,/^$/ s/^#Color/Color/' /etc/pacman.conf
sudo sed -i '/^\[options\]/,/^$/ s/^#ParallelDownload = 5/ParallelDownload = 5/' /etc/pacman.conf
echo -e "\n[archlinuxcn]\nServer = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch" | sudo tee -a /etc/pacman.conf > /dev/null

# /etc/pacman.d/mirrorlist
sudo sed -i '1iServer = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
sudo sed -i '2iServer = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist

sudo pacman -Syu
sudo pacman -S archlinuxcn-keyring
sudo pacman -S --noconfirm paru wget neofetch btop htop xdg-utils xdg-user-dirs trash-cli cronie
sudo systemctl enable cronie --now

# zramd
paru -S --noconfirm zramd
sudo systemctl enable --now zramd.service --now

# bluetooth
sudo pacman -S --noconfirm bluez bluez-utils blueman
echo "btusb" | sudo tee /etc/modules-load.d/bluetooth.conf
echo "AutoEnable=true" | sudo tee -a /etc/bluetooth/main.conf > /dev/null
sudo systemctl enable bluetooth --now

# audio
sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse gst-plugin-pipewire wireplumber
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now pipewire.socket
systemctl --user enable --now wireplumber.service

xdg-user-dirs-update
