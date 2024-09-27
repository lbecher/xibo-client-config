#!/bin/bash

#---------------------------------------
# Atualizando o sistema
sudo apt update
sudo apt upgrade

#---------------------------------------
# Instalando dependências
sudo apt install wget tar sway rofi foot xwayland xdg-desktop-portal xdg-desktop-portal-gtk at-spi2-core snapd

#---------------------------------------
# Configurando o sway
mkdir -p ~/.config/foot
mkdir -p ~/.config/sway
cp foot_ini ~/.config/foot/foot.ini
cp sway_config ~/.config/sway/config

#---------------------------------------
# Instalando dependências
wget https://github.com/lbecher/xibo-linux/releases/download/1.8-R7-alpha1/xibo-player_1.8-R7-alpha1_armhf.snap
sudo snap install --dangerous xibo-player_1.8-R7-alpha1_armhf.snap
