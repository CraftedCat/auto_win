#!/usr/bin/env bash
INSTALL_FILE="install_12900k.sh"

wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/$INSTALL_FILE
if [ -z "$1" ]; then
    echo "Использование: $0 <пароль для WebServer c файлами>"
    exit 1
fi

PASSWORD_INSTALL="$1"

if [ -f $INSTALL_FILE ]; then
    sed -i "s|{{password}}|$PASSWORD_INSTALL|g" $INSTALL_FILE
else
    echo "Файл install_12900k.sh не найден!"
fi

bash $INSTALL_FILE