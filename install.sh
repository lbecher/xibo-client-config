#!/bin/bash

#---------------------------------------
# Identifica a arquitetura do sistema e seta variáveis
BASE_URL="https://github.com/lbecher/xibo-client-config/releases/download/v0.3.0"
ARCH=$(uname -m)
case "$ARCH" in
    "x86_64")
        FILE="xibo-player-1.8-R7-amd64-portable.tar.gz"
        ;;
    "armv7l")
        FILE="xibo-player-1.8-R7-armhf-portable.tar.gz"
        ;;
    "aarch64")
        FILE="xibo-player-1.8-R7-arm64-portable.tar.gz"
        ;;
    *)
        echo "Arquitetura não suportada: $ARCH"
        exit 1
        ;;
esac

#---------------------------------------
# Instalando dependências
sudo apt update
sudo apt install \
    wget \
    tar \
    pulseaudio \
    pulseaudio-utils \
    pavucontrol \
    paprefs \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-wlr \
    xwayland \
    sway \
    rofi \
    alacritty \
    at-spi2-core \
    gvfs \
    gvfs-backends \
    thunar \
    network-manager-gnome

#---------------------------------------
# Configurando o início automático
sudo cp /usr/lib/systemd/system/getty@.service /etc/systemd/system/autologin@.service
EXEC_START="ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin xibo %I \$TERM"
sudo sudo sed -i 's|^ExecStart=.*|'"$EXEC_START"'|' /etc/systemd/system/autologin@.service
sudo systemctl disable getty@tty1
sudo systemctl enable autologin@tty1.service
touch ~/.bash_profile
echo 'if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    WLR_LIBINPUT_NO_DEVICES=1 exec sway
fi' > ~/.bash_profile

#---------------------------------------
# Configurando o sway
mkdir -p ~/.config/sway
cp sway_config ~/.config/sway/config

#---------------------------------------
# Instalando dependências
wget "$BASE_URL/$FILE"
tar -xzf "$FILE"
sudo mv xibo-player-1.8-R7-amd64-portable /opt/xibo-player
sudo ln -s /opt/xibo-player/xibo-options.sh /usr/local/bin/xibo-options
sudo ln -s /opt/xibo-player/xibo-player.sh /usr/local/bin/xibo-player
