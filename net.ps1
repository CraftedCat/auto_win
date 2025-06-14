# Включение режима тестовой подписи
Start-Process -FilePath "bcdedit.exe" -ArgumentList "/set testsigning on" -Verb RunAs
Start-Process -FilePath "bcdedit.exe" -ArgumentList "/set nointegritychecks on" -Verb RunAs

# Настройка сети
foreach ($Adapter in Get-NetAdapter) {
#     New-NetIPAddress -IPAddress [IPAdresse] -DefaultGateway [Gateway] -PrefixLength [CIDR] -InterfaceIndex $Adapter.InterfaceIndex
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

# Распаковка архива с драйверами
$volumes = Get-Volume | Where-Object { $_.DriveLetter -ne $null }

foreach ($vol in $volumes) {
    $zipPathNIC = "$($vol.DriveLetter):\PRO1000.zip"
    $zipPathWDK = "$($vol.DriveLetter):\x64.zip"
    if (Test-Path $zipPath) {
        $extractTo = "C:\"
        Expand-Archive -Path $zipPathNIC -DestinationPath $extractTo -Force
        Expand-Archive -Path $zipPathWDK -DestinationPath $extractTo -Force
        break
    }
}
