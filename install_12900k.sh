#!/usr/bin/env bash
BOLD='\033[1m'       #  ${BOLD}
LGREEN='\033[1;32m'     #  ${LGREEN}
LBLUE='\033[1;34m'     #  ${LBLUE}
BGGREEN='\033[42m'     #  ${BGGREEN}
BGGRAY='\033[47m'     #  ${BGGRAY}
BREAK='\033[m'       #  ${BREAK}
regex='^[0-9]+$'

# ENV
MIRROR="https://mirror.gameservers.me"
MIR_USER="XLGAMES"
MIR_PASSWD="{{password}}"
GOLDEN_IMAGE="Golden.img.zst"

######### Определение первого доступного диска (исключая loop и removable) ###########
TARGET_DISK=$(lsblk -dn -o NAME,RM,TYPE | awk '$2 == 0 && $3 == "disk" && $1 !~ /^loop/ {print $1; exit}')
if [ -z "$TARGET_DISK" ]; then
    echo "Ошибка: не удалось определить целевой диск."
    exit 1
fi
DISK_DEVICE="/dev/$TARGET_DISK"
echo -e "Выбран диск: ${LGREEN}$DISK_DEVICE${BREAK}"
#####################################

######### Загрузка golden image ###########
cd /mnt || exit
# Проверка, существует ли локальный файл
if [ -f "$GOLDEN_IMAGE" ]; then
    echo "Локальный файл $GOLDEN_IMAGE уже существует. Проверяем размер..."

    # Получение размера удалённого файла в байтах
    REMOTE_SIZE=$(wget --user="$MIR_USER" --password="$MIR_PASSWD" --spider --server-response "$MIRROR/$GOLDEN_IMAGE" 2>&1 \
        | awk '/Content-Length/ {print $2}' | tail -1)

    # Получение размера локального файла
    LOCAL_SIZE=$(stat -c %s "$GOLDEN_IMAGE")

    if [ "$REMOTE_SIZE" = "$LOCAL_SIZE" ]; then
        echo "Файл уже загружен и соответствует по размеру. Пропускаем загрузку."
    else
        echo "Размеры не совпадают. Повторная загрузка..."
        wget --continue --user="$MIR_USER" --password="$MIR_PASSWD" "$MIRROR/$GOLDEN_IMAGE"
    fi
else
    echo "Файл не найден. Загрузка..."
    wget --user="$MIR_USER" --password="$MIR_PASSWD" "$MIRROR/$GOLDEN_IMAGE"
fi
#####################################

######### Запись golden image ###########
zstd -d --stdout /mnt/win_image.img.zst | dd of="$DISK_DEVICE" bs=256M
sync
#####################################

reboot