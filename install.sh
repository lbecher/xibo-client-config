#!/bin/bash

#---------------------------------------
# Identifica a arquitetura do sistema e seta variáveis
BASE_URL="https://github.com/lbecher/xibo-client-config/releases/download/v0.2.0"
ARCH=$(uname -m)
case "$ARCH" in
    "x86_64")
        FILE="xibo-player_1.8-R7_amd64.snap"
        ;;
    "armv7l")
        FILE="xibo-player_1.8-R7_armhf.snap"
        ;;
    "aarch64")
        FILE="xibo-player_1.8-R7_arm64.snap"
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
    snapd \
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
    exec sway
fi' > ~/.bash_profile

#---------------------------------------
# Configurando o sway
mkdir -p ~/.config/sway
cp sway_config ~/.config/sway/config

#---------------------------------------
# Instalando dependências
wget "$BASE_URL/$FILE"
sudo snap install --dangerous "$FILE"
