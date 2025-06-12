# powershell.exe -ExecutionPolicy Bypass -Command "Get-Volume | Where-Object { $_.DriveType -eq 'CD-ROM' } | ForEach-Object { if (Test-Path ($_.DriveLetter + ':\net.ps1')) { & ($_.DriveLetter + ':\net.ps1') } }"
# Настройка сети
foreach ($Adapter in Get-NetAdapter) {
    New-NetIPAddress -IPAddress [IPAdresse] -DefaultGateway [Gateway] -PrefixLength [CIDR] -InterfaceIndex $Adapter.InterfaceIndex
    Set-DnsClientServerAddress -InterfaceIndex $Adapter.InterfaceIndex -ServerAddresses "8.8.8.8", "1.1.1.1"
}

# Найти CD-ROM с нужным скриптом
$cdrom = Get-Volume | Where-Object { $_.DriveType -eq 'CD-ROM' -and (Test-Path "$($_.DriveLetter):\enable-rdp.ps1") } | Select-Object -First 1

if ($cdrom) {
    $source = "$($cdrom.DriveLetter):\enable-rdp.ps1"
    $destination = "C:\enable-rdp.ps1"

    # Копирование скрипта
    Copy-Item -Path $source -Destination $destination -Force

    # Создание задания на запуск скрипта при старте
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\enable-rdp.ps1"
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    Register-ScheduledTask -TaskName "EnableRDP" -Action $Action -Trigger $Trigger -RunLevel Highest -User "SYSTEM"
}

$volumes = Get-Volume | Where-Object { $_.DriveLetter -ne $null }

foreach ($vol in $volumes) {
    $zipPath = "$($vol.DriveLetter):\PRO1000.zip"
    if (Test-Path $zipPath) {
        $extractTo = "C:\"
        Expand-Archive -Path $zipPath -DestinationPath $extractTo -Force
        break
    }
}