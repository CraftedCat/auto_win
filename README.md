

# Add drivers 
# Index 2: Windows Server 2022 Standard (возможности рабочего стола)

[//]: # (dism /Mount-Wim /WimFile:D:\ISO\sources\boot.wim /Index:2 /MountDir:D:\Mount)

[//]: # (dism /Image:D:\Mount /Add-Driver /Driver:D:\Drivers\IntelNVMe /Recurse)

[//]: # (dism /Unmount-Wim /MountDir:D:\Mount /Commit)

dism /Mount-Wim /WimFile:D:\ISO\sources\install.wim /Index:2 /MountDir:D:\Mount
dism /Image:D:\Mount /Add-Driver /Driver:D:\Drivers\IntelNVMe /Recurse
dism /Unmount-Wim /MountDir:D:\Mount /Commit

# Build ISO
oscdimg -m -o -u2 -udfver102 -bootdata:2#p0,e,bD:\ISO\boot\etfsboot.com#pEF,e,bD:\ISO\efi\microsoft\boot\efisys.bin D:\ISO D:\CustomServer2022.iso

oscdimg -m -o -u2 -udfver102 -bootdata:2#p0,e,bD:\ISO\boot\etfsboot.com#pEF,e,bD:\ADK\efisys_noprompt.bin D:\ISO D:\CustomServer2022-UEFI-Only.iso
oscdimg -m -o -u2 -udfver102 -bootdata:1#pEF,e,bD:\ADK\efisys_noprompt.bin D:\ISO D:\CustomServer2022-UEFI-Only.iso

## Get NIC INTEL REAL OK
# Windows
Get-PnpDevice -Class Net | Where-Object { $_.Status -eq "OK" } | Format-List 
PCI\VEN_8086&DEV_1A1D  -  I219-LM 

# Linux
lspci -nn | grep -i ethernet
lspci 00:1f.6