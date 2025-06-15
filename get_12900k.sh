#!/usr/bin/env bash

wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/install_12900k.sh
if [ -z "$1" ]; then
    echo "Использование: $0 <пароль для WebServer c файлами>"
    exit 1
fi

PASSWORD_INSTALL="$1"


# Замена {{password}} в install.sh
if [ -f install_12900k.sh ]; then
    sed -i "s|{{password}}|$PASSWORD_INSTALL|g" install_12900k.sh
else
    echo "Файл install_12900k.sh не найден!"
fi

bash install_12900k.sh