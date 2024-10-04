#!/bin/bash

#---------------------------------------
# Atualizando o sistema
sudo apt update
sudo apt upgrade

#---------------------------------------
# Instalando dependências
sudo apt install \
    wget \
    tar \
    pipewire \
    pipewire-alsa \
    pipewire-jack \
    pipewire-pulse \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-wlr \
    xwayland \
    sway \
    rofi \
    foot \
    snapd \
    at-spi2-core

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
mkdir -p ~/.config/foot
mkdir -p ~/.config/sway
cp foot_ini ~/.config/foot/foot.ini
cp sway_config ~/.config/sway/config

#---------------------------------------
# Instalando dependências
wget https://github.com/lbecher/xibo-linux/releases/download/1.8-R7/xibo-player_1.8-R7_armhf.snap
sudo snap install --dangerous xibo-player_1.8-R7_armhf.snap
