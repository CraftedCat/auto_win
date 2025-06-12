

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


Caption                     : Intel(R) Ethernet Connection (9) I219-LM
Description                 : Intel(R) Ethernet Connection (9) I219-LM
InstallDate                 : 
Name                        : Intel(R) Ethernet Connection (9) I219-LM
Status                      : OK
Availability                : 
ConfigManagerErrorCode      : CM_PROB_NONE
ConfigManagerUserConfig     : False
CreationClassName           : Win32_PnPEntity
DeviceID                    : PCI\VEN_8086&DEV_1A1D&SUBSYS_86721043&REV_11\3&11583659&0&FE
ErrorCleared                : 
ErrorDescription            : 
LastErrorCode               : 
PNPDeviceID                 : PCI\VEN_8086&DEV_1A1D&SUBSYS_86721043&REV_11\3&11583659&0&FE
PowerManagementCapabilities : 
PowerManagementSupported    : 
StatusInfo                  : 
SystemCreationClassName     : Win32_ComputerSystem
SystemName                  : XLADMIN-BI20O2P
ClassGuid                   : {4d36e972-e325-11ce-bfc1-08002be10318}
CompatibleID                : {PCI\VEN_8086&DEV_1A1D&REV_11, PCI\VEN_8086&DEV_1A1D, PCI\VEN_8086&CC_020000, PCI\VEN_8086&CC_0200...}
HardwareID                  : {PCI\VEN_8086&DEV_1A1D&SUBSYS_86721043&REV_11, PCI\VEN_8086&DEV_1A1D&SUBSYS_86721043, PCI\VEN_8086&DEV_1A1D&CC_020000, PC
                              I\VEN_8086&DEV_1A1D&CC_0200}
Manufacturer                : Intel Corporation
PNPClass                    : Net
Present                     : True
Service                     : e1i68x64
PSComputerName              : 
Class                       : Net
FriendlyName                : Intel(R) Ethernet Connection (9) I219-LM
InstanceId                  : PCI\VEN_8086&DEV_1A1D&SUBSYS_86721043&REV_11\3&11583659&0&FE
Problem                     : CM_PROB_NONE
ProblemDescription          : 
 


# Linux
lspci -nn | grep -i ethernet
lspci 00:1f.6