#!/usr/bin/env bash
wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/install.sh
wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/net.ps1
wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/enable-rdp.ps1
wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/autounattend_bios.xml
wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/autounattend_uefi.xml
wget https://raw.githubusercontent.com/CraftedCat/auto_win/refs/heads/main/autounattend_uefi.xml

if [ -z "$1" ]; then
    echo "Использование: $0 <пароль>"
    exit 1
fi

PASSWORD="$1"

# Экранируем спецсимволы пароля для безопасной замены в sed
ESCAPED_PASSWORD=$(printf '%s\n' "$PASSWORD" | sed 's/[&/\]/\\&/g')

# Заменяем {{password}} в файлах
sed -i "s/{{password}}/$ESCAPED_PASSWORD/g" autounattend_bios.xml
sed -i "s/{{password}}/$ESCAPED_PASSWORD/g" autounattend_uefi.xml

echo "Пароль вставлен в XML-файлы."

bash install.sh