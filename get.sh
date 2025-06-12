#!/usr/bin/env bash

wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/install.sh
wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/net.ps1
wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/enable-rdp.ps1
wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/autounattend_bios.xml
wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/autounattend_uefi.xml
wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/autounattend_uefi.xml

#!/bin/bash

# Проверка: оба пароля должны быть заданы
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Использование: $0 <пароль для Windows Администратор> <пароль для WebServer c файлами>"
    exit 1
fi

PASSWORD_XML="$1"
PASSWORD_INSTALL="$2"

# Замена {{password}} в autounattend_bios.xml и autounattend_uefi.xml
for file in autounattend_bios.xml autounattend_uefi.xml; do
    if [ -f "$file" ]; then
        sed -i "s|{{password}}|$PASSWORD_XML|g" "$file"
    else
        echo "Файл $file не найден!"
    fi
done

# Замена {{password}} в install.sh
if [ -f install.sh ]; then
    sed -i "s|{{password}}|$PASSWORD_INSTALL|g" install.sh
else
    echo "Файл install.sh не найден!"
fi