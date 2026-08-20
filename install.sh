#!/bin/bash

set -e

#---------------------------------------
# Configurações gerais

XIBO_VERSION="${XIBO_VERSION:-4.0.9}"
AUTOLOGIN_USER="${AUTOLOGIN_USER:-xibo}"
AUTOLOGIN_HOME="/home/${AUTOLOGIN_USER}"

BASE_URL="https://github.com/lbecher/xibo-client-config/releases/download/v${XIBO_VERSION}"

#---------------------------------------
# Identifica a arquitetura do sistema

ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    amd64|arm64)
        FILE="xibo-player_${XIBO_VERSION}_${ARCH}.deb"
        ;;
    *)
        echo "Arquitetura não suportada: $ARCH"
        exit 1
        ;;
esac

echo "Arquitetura detectada: $ARCH"
echo "Pacote Xibo: $FILE"

#---------------------------------------
# Verifica se o usuário xibo existe

if ! id "$AUTOLOGIN_USER" >/dev/null 2>&1; then
    echo "Usuário '$AUTOLOGIN_USER' não existe."
    echo "Criando usuário..."

    sudo useradd \
        --create-home \
        --shell /bin/bash \
        "$AUTOLOGIN_USER"
fi

# Garante que o diretório home existe
sudo mkdir -p "$AUTOLOGIN_HOME"
sudo chown "$AUTOLOGIN_USER:$AUTOLOGIN_USER" "$AUTOLOGIN_HOME"

#---------------------------------------
# Instalando dependências

sudo apt update

sudo apt install -y \
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
# Configurando autologin no tty1
#
# Em vez de criar um autologin@.service separado,
# sobrescrevemos apenas o ExecStart do getty@tty1.

echo "Configurando autologin para '$AUTOLOGIN_USER'..."

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d

sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${AUTOLOGIN_USER} --noclear %I \$TERM
EOF

sudo systemctl daemon-reload
sudo systemctl enable getty@tty1.service

# Caso uma versão anterior deste script tenha criado
# autologin@tty1.service, desativa para evitar conflito.

if systemctl list-unit-files | grep -q '^autologin@\.service'; then
    sudo systemctl disable autologin@tty1.service 2>/dev/null || true
fi

#---------------------------------------
# Configurando inicialização automática do Sway

echo "Configurando início automático do Sway..."

sudo tee "$AUTOLOGIN_HOME/.bash_profile" >/dev/null <<'EOF'
# Inicia o Sway automaticamente somente no tty1.
#
# DISPLAY vazio:
#   evita tentar iniciar outra sessão gráfica X11.
#
# WAYLAND_DISPLAY vazio:
#   evita iniciar um segundo compositor Wayland.
#
# tty1:
#   garante que conexões SSH e outros terminais
#   não iniciem o Sway.

if [[ -z "$DISPLAY" ]] && \
   [[ -z "$WAYLAND_DISPLAY" ]] && \
   [[ "$(tty)" == "/dev/tty1" ]]; then

    exec env WLR_LIBINPUT_NO_DEVICES=1 sway
fi
EOF

sudo chown "$AUTOLOGIN_USER:$AUTOLOGIN_USER" \
    "$AUTOLOGIN_HOME/.bash_profile"

sudo chmod 644 "$AUTOLOGIN_HOME/.bash_profile"

#---------------------------------------
# Configurando o Sway

echo "Configurando Sway..."

sudo -u "$AUTOLOGIN_USER" mkdir -p \
    "$AUTOLOGIN_HOME/.config/sway"

if [[ ! -f "sway_config" ]]; then
    echo "Erro: arquivo sway_config não encontrado."
    exit 1
fi

sudo cp \
    sway_config \
    "$AUTOLOGIN_HOME/.config/sway/config"

sudo chown -R \
    "$AUTOLOGIN_USER:$AUTOLOGIN_USER" \
    "$AUTOLOGIN_HOME/.config"

#---------------------------------------
# Instalando o Xibo Player

echo "Baixando Xibo Player ${XIBO_VERSION}..."

DEB_PATH=$(mktemp --suffix=.deb)

cleanup() {
    rm -f "$DEB_PATH"
}

trap cleanup EXIT

wget \
    --output-document="$DEB_PATH" \
    "$BASE_URL/$FILE"

echo "Instalando Xibo Player..."

sudo apt install -y "$DEB_PATH"

#---------------------------------------
# Ajustando permissões finais

sudo chown -R \
    "$AUTOLOGIN_USER:$AUTOLOGIN_USER" \
    "$AUTOLOGIN_HOME"

#---------------------------------------
# Recarrega configuração do systemd

sudo systemctl daemon-reload
