# Xibo Player em TV Box com Sway e Snap

Este projeto permite a instalação e execução do **Xibo Player 1.8-R7** em dispositivos **ARM ou x86**, utilizando o gerenciador de janelas **Sway** em ambiente **Wayland**.

## Requisitos

- Dispositivo com arquitetura compatível (`armv7l`, `aarch64` ou `x86_64`)
- Conexão com a internet
- Distribuição Linux baseada em Debian

Para usuários de TV Box, pode-se baixar imagens compatíveis em:

- [ophub/amlogic-s9xxx-armbian](https://github.com/ophub/amlogic-s9xxx-armbian)
- [devmfc/debian-on-amlogic](https://github.com/devmfc/debian-on-amlogic)

## Criar usuário `xibo`

No Armbian, o usuário poder ser criado pelo setup inicial. Importante: escolha Bash quando solicitado. No DevMFC, é necessário criar o usuário utilizando linha de comando, após login como root:

```bash
adduser xibo -m -s /bin/bash
usermod -aG sudo xibo
passwd xibo
```

## Instalação do Xibo

Primeiro, faça login com o usuário `xibo`. Depois, instale o `git` e clone esse repositório:

```bash
sudo apt update
sudo apt install git
git clone https://github.com/lbecher/xibo-client-config
```

Por fim, execute o script de instalação:

```bash
cd xibo-client-config
chmod +x install.sh
./install.sh
```

## Atalhos de Teclado

| Atalho                | Ação                                           |
|-----------------------|------------------------------------------------|
| `Super + X`           | Iniciar Xibo Player                            |
| `Super + O`           | Abrir configurações do Xibo                    |
| `Super + T`           | Abrir terminal (Alacritty)                     |
| `Super + M`           | Abrir menu (Rofi)                              |
| `Super + A`           | Abrir controle de áudio (pavucontrol)         |
| `Super + N`           | Abrir navegador de arquivos (Thunar)          |
| `Super + I`           | Abrir editor de conexões de rede              |
| `Super + F`           | Fechar janela ativa                            |
| `Super + ← / ↓ / ↑ / →` | Mover foco entre janelas                    |
| `Super + Shift + L`   | Recarregar o Sway                              |
| `Super + Shift + F`   | Fechar o Sway (com confirmação)               |


Observação: `Super` geralmente é a tecla **Windows**.
