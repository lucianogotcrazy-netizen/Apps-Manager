#!/bin/bash

# Elevate sudo
sudo -v || exit 1
( while true; do sudo -v; sleep 60; done ) &
SUDO_LOOP_PID=$!

# URL del paquete remoto
REMOTE_NEW="PLACEHOLDER"

# Colors
GREEN="\e[92m"
NC="\e[0m"

# Ensure dialog, git, base-devel, jq, curl are installed
for pkg in dialog git base-devel jq curl; do
    if ! command -v $pkg &>/dev/null; then
        sudo pacman -S --needed $pkg --noconfirm
    fi
done

sudo pacman -S wget --noconfirm

# Descargar instalador
wget "$REMOTE_NEW" -O ~/.tmp.tar.gz

# Crear carpeta temporal
mkdir -p ~/.tmpdir
cd ~/.tmpdir || exit 1

# Extraer (seguro sin cambiar propietarios)
tar xpf ~/.tmp.tar.gz --no-same-owner

# Instalar en /usr/local/apps
sudo mkdir -p /usr/local/apps
sudo rm -rf /usr/local/apps/*
sudo mv * /usr/local/apps/

# Crear symlink si no existe
if [ ! -f /usr/local/bin/apps ]; then
    sudo ln -s /usr/local/apps/check_update.sh /usr/local/bin/apps
fi

# Asegurar permisos
sudo chmod +x /usr/local/apps/*

rm -rf ~/.tmp.tar.gz ~/.tmpdir
# Done
dialog --title "Setup Complete" --msgbox "Ejecuta 'apps' en la terminal" 8 50

kill "$SUDO_LOOP_PID"
clear
echo -e "${GREEN}Installer finished.${NC}"
