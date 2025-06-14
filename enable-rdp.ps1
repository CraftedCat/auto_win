# 1. Разрешить RDP в реестре
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

# 2. Убедиться, что служба TermService работает
Set-Service -Name TermService -StartupType Automatic
Start-Service -Name TermService

# 3. Дополнительно — включить поддержку RDP на уровне WMI (как делает GUI)
(Get-WmiObject -Namespace root\cimv2\terminalservices -Class Win32_TerminalServiceSetting).SetAllowTSConnections(1,1)

$driverPath = "C:\PRO1000_OLD\NDIS68"
$infPath = "$driverPath\e1r.inf"
$devconPath = "C:\devcon.exe"
$targetId = "PCI\VEN_8086&DEV_1A1D"
$deviceIdToUse = "PCI\VEN_8086&DEV_1A1D&SUBSYS_86721043"

# Поиск устройств с нужным HardwareID
$devices = Get-CimInstance Win32_PnPEntity | Where-Object {
    $_.PNPClass -eq "Net" -and $_.HardwareID -match [regex]::Escape($targetId)
}

if (-not $devices) {
    Write-Host "Нет устройств с HardwareID: $targetId"
    exit
}

Write-Host "Найдено устройств: $($devices.Count)"

# Принудительная установка драйвера с devcon
foreach ($dev in $devices) {
    Write-Host "Привязка драйвера к устройству: $($dev.DeviceID)"
    try {
        Start-Process -FilePath $devconPath -ArgumentList "update `"$infPath`" `"$deviceIdToUse`"" -Wait -NoNewWindow
    } catch {
        Write-Warning "Не удалось обновить драйвер: $_"
    }
}



