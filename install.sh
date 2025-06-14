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
#CDROM_ISO="SW_DVD9_Win_Server_STD_CORE_2022__64Bit_Russian_DC_STD_MLF_X22-74303.ISO"
CDROM_ISO="CustomServer2022.iso"
VNC_ADDRESS="127.0.0.1:1"
KEYBOARD_LAYOUT="en-us"


######### Определяем BIOS ###########
if [ -d "/sys/firmware/efi" ]; then
    BOOT_TYPE="UEFI"
else
    BOOT_TYPE="BIOS"
fi
echo -e "Boot mode определен как: ${LGREEN}$BOOT_TYPE${BREAK}"
#####################################


######### Определение первого доступного диска (исключая loop и removable) ###########
TARGET_DISK=$(lsblk -dn -o NAME,RM,TYPE | awk '$2 == 0 && $3 == "disk" && $1 !~ /^loop/ {print $1; exit}')
if [ -z "$TARGET_DISK" ]; then
    echo "Ошибка: не удалось определить целевой диск."
    exit 1
fi
DISK_DEVICE="/dev/$TARGET_DISK"
echo -e "Выбран диск: ${LGREEN}$DISK_DEVICE${BREAK}"
#####################################

######### Определение размера диска в байтах и разметка ###########
DISK_SIZE_BYTES=$(lsblk -b -dn -o SIZE "$DISK_DEVICE")
if [ "$DISK_SIZE_BYTES" -lt $((2 * 1024**4)) ]; then  # меньше 2 ТБ
    PART_LABEL="msdos"
else
    PART_LABEL="gpt"
fi

echo -e "Создание таблицы разделов ${LGREEN}($PART_LABEL)${BREAK} на ${LGREEN}$DISK_DEVICE${BREAK}..."
parted -s "$DISK_DEVICE" mklabel "$PART_LABEL"
echo -e "${LGREEN}Диск создан!${BREAK}"
#####################################

######### Загрузка virtio-win ISO, если UEFI ###########
if [ "$BOOT_TYPE" == "UEFI" ]; then
    echo "UEFI режим: загружаем драйверы..."
    VIRTIO_ISO="/tmp/virtio-win.iso"
    NIC_DRIVERS="PRO1000_OLD.zip"
    DEVCON="devcon.exe"

    if [ -f "$VIRTIO_ISO" ]; then
        echo "virtio-win.iso уже существует. Пропускаем загрузку."
    else
        wget -O "$VIRTIO_ISO" https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
    fi

    if [ -f "$NIC_DRIVERS" ]; then
        echo "$NIC_DRIVERS уже существует. Пропускаем загрузку."
    else
        wget -O "$NIC_DRIVERS" https://github.com/CraftedCat/auto_win/raw/refs/heads/main/$NIC_DRIVER
        wget -O "$DEVCON" https://github.com/CraftedCat/auto_win/raw/refs/heads/main/$DEVCON
    fi
fi
#####################################

######### Создание ISO авто-ответов ###########
apt install -y ovmf genisoimage

if [ -f /tmp/autounattend.iso ]; then
  rm /tmp/autounattend.iso
else
  echo "Файл /tmp/autounattend.iso ещё не создан — пропускаем удаление."
fi

mkdir -p /tmp/win-autounattend
if [ "$BOOT_TYPE" == "UEFI" ]; then
  cp autounattend_uefi.xml /tmp/win-autounattend/autounattend.xml
  cp $NIC_DRIVERS /tmp/win-autounattend/
  cp $DEVCON /tmp/win-autounattend/
else
  cp autounattend_bios.xml /tmp/win-autounattend/autounattend.xml
fi

cp net.ps1 /tmp/win-autounattend/
cp enable-rdp.ps1 /tmp/win-autounattend/
genisoimage -o /tmp/autounattend.iso -V "AUTO_WIN" -J -r /tmp/win-autounattend
##############################################

######### Загрузка образа Windows-сервера ###########
cd /tmp || exit
# Проверка, существует ли локальный файл
if [ -f "$CDROM_ISO" ]; then
    echo "Локальный файл $CDROM_ISO уже существует. Проверяем размер..."

    # Получение размера удалённого файла в байтах
    REMOTE_SIZE=$(wget --user="$MIR_USER" --password="$MIR_PASSWD" --spider --server-response "$MIRROR/$CDROM_ISO" 2>&1 \
        | awk '/Content-Length/ {print $2}' | tail -1)

    # Получение размера локального файла
    LOCAL_SIZE=$(stat -c %s "$CDROM_ISO")

    if [ "$REMOTE_SIZE" = "$LOCAL_SIZE" ]; then
        echo "Файл уже загружен и соответствует по размеру. Пропускаем загрузку."
    else
        echo "Размеры не совпадают. Повторная загрузка..."
        wget --continue --user="$MIR_USER" --password="$MIR_PASSWD" "$MIRROR/$CDROM_ISO"
    fi
else
    echo "Файл не найден. Загрузка..."
    wget --user="$MIR_USER" --password="$MIR_PASSWD" "$MIRROR/$CDROM_ISO"
fi
#####################################



######### Запуск QEMU ###########
if [ "$BOOT_TYPE" == "UEFI" ]; then
    echo "Starting QEMU with UEFI firmware..."
    cp /usr/share/OVMF/OVMF_VARS.fd /tmp/OVMF_VARS.fd

    qemu-system-x86_64 \
        -enable-kvm \
        -machine q35 \
        -cpu host \
        -smp 2 \
        -m 8G \
        -vnc "$VNC_ADDRESS" \
        -k "$KEYBOARD_LAYOUT" \
        -usbdevice tablet \
        -net nic \
        -net user,hostfwd=tcp::3389-:3389 \
        -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
        -drive if=pflash,format=raw,file=/tmp/OVMF_VARS.fd \
        -cdrom "$CDROM_ISO" \
        -drive file=/tmp/autounattend.iso,media=cdrom \
        -drive file="$DISK_DEVICE",format=raw,media=disk,if=virtio \
        -drive file=/tmp/virtio-win.iso,media=cdrom,if=ide \
        -monitor tcp:127.0.0.1:4444,server,nowait &
    QEMU_PID=$!
    sleep 1
    echo "sendkey ret" | nc -q 1 127.0.0.1 4444
    sleep 1
    echo "sendkey ret" | nc -q 1 127.0.0.1 4444
    sleep 1
    echo "sendkey ret" | nc -q 1 127.0.0.1 4444
    sleep 1
    echo "sendkey ret" | nc -q 1 127.0.0.1 4444
    wait $QEMU_PID
else
    echo "Starting QEMU with BIOS firmware..."
    qemu-system-x86_64 \
        -enable-kvm \
        -smp 2 \
        -m 8G \
        -cpu host \
        -k "$KEYBOARD_LAYOUT" \
        -usbdevice tablet \
        -vnc "$VNC_ADDRESS" \
        -net nic \
        -net user,hostfwd=tcp::3389-:3389 \
        -drive file="$DISK_DEVICE",format=raw,media=disk \
        -cdrom "$CDROM_ISO" \
        -drive file=/tmp/autounattend.iso,media=cdrom \
        -boot order=d
fi
#####################################