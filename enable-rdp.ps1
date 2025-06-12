# 1. Разрешить RDP в реестре
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

# 2. Убедиться, что служба TermService работает
Set-Service -Name TermService -StartupType Automatic
Start-Service -Name TermService

# 3. Дополнительно — включить поддержку RDP на уровне WMI (как делает GUI)
(Get-WmiObject -Namespace root\cimv2\terminalservices -Class Win32_TerminalServiceSetting).SetAllowTSConnections(1,1)

$driverPath = "C:\PRO1000\Winx64\WS2022_CUSTOM"
$targetId = "PCI\VEN_8086&DEV_1A1D"
$devices = Get-CimInstance Win32_PnPEntity | Where-Object {
    $_.PNPClass -eq "Net" -and $_.HardwareID -match [regex]::Escape($targetId)
}


if (-not $devices) {
    Write-Host "Нет устройств с HardwareID: $targetId"
} else {
    Write-Host "Найдено устройств: $($devices.Count)"

    # Установка драйверов из указанной директории (включая поддиректории)
    pnputil /add-driver "$driverPath\*.inf" /subdirs /install

    # Переустановка устройств
    foreach ($dev in $devices) {
        try {
            Write-Host "Переустановка драйвера для: $($dev.InstanceId)"
            Disable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction Stop
            Start-Sleep -Seconds 2
            Enable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction Stop
        } catch {
            Write-Warning "Ошибка переустановки для $($dev.InstanceId): $_"
        }
    }
}



