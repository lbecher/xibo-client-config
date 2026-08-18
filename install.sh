#!/bin/bash

#---------------------------------------
# Identifica a arquitetura do sistema e seta variáveis
XIBO_VERSION="${XIBO_VERSION:-4.0.9}"
BASE_URL="https://github.com/lbecher/xibo-client-config/releases/download/v${XIBO_VERSION}"
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    "amd64"|"arm64")
        FILE="xibo-player_${XIBO_VERSION}_${ARCH}.deb"
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
DEB_PATH=$(mktemp --suffix=.deb)
trap 'rm -f "$DEB_PATH"' EXIT
wget --output-document="$DEB_PATH" "$BASE_URL/$FILE"
sudo apt install -y "$DEB_PATH"
