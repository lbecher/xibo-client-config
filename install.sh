#!/bin/bash

set -e

#---------------------------------------
# Variáveis

BASE_URL="https://github.com/lbecher/xibo-client-config/releases/download/v0.3.0"
ARCH=$(uname -m)

case "$ARCH" in
"aarch64")
FILE="xibo-player_arm64.deb"
;;
*)
echo "Arquitetura não suportada: $ARCH"
exit 1
;;
esac

#---------------------------------------
# Sistema

sudo apt update

#---------------------------------------
# PipeWire

sudo apt install -y \
pipewire \
pipewire-audio \
pipewire-pulse \
wireplumber \
libspa-0.2-bluetooth \
pavucontrol

#---------------------------------------
# Wayland + Sway + Portal

sudo apt install -y \
xdg-desktop-portal \
xdg-desktop-portal-wlr \
xwayland \
sway \
rofi \
alacritty \
thunar

#---------------------------------------
# Rede

sudo apt install -y network-manager network-manager-gnome
sudo systemctl stop systemd-networkd || true
sudo systemctl disable systemd-networkd || true
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

#---------------------------------------
# Habilita PipeWire (usuário)

systemctl --user enable pipewire
systemctl --user enable pipewire-pulse
systemctl --user enable wireplumber

#---------------------------------------
# Portal config (evita conflitos)

mkdir -p ~/.config/xdg-desktop-portal
cat > ~/.config/xdg-desktop-portal/portals.conf <<EOF
[preferred]
default=wlr
EOF

#---------------------------------------
# Autologin

sudo cp /usr/lib/systemd/system/getty@.service /etc/systemd/system/autologin@.service
EXEC_START="ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin xibo %I $TERM"
sudo sed -i "s|^ExecStart=.*|$EXEC_START|" /etc/systemd/system/autologin@.service
sudo systemctl disable getty@tty1
sudo systemctl enable [autologin@tty1.service](mailto:autologin@tty1.service)

#---------------------------------------
# Auto start sway

cat > ~/.bash_profile <<'EOF'
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway
export MOZ_ENABLE_WAYLAND=1
exec sway
fi
EOF

#---------------------------------------
# Config sway

mkdir -p ~/.config/sway
cp sway_config ~/.config/sway/config

#---------------------------------------
# Timezone

sudo timedatectl set-timezone America/Sao_Paulo

#---------------------------------------
# Xibo

wget "$BASE_URL/$FILE"
sudo dpkg -i "$FILE"

