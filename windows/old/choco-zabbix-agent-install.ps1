# Define the registry path where Zabbix Agent 2 version might be stored
# Note: This is a hypothetical path; you'll need to replace it with the actual registry path
$registryPath = "HKLM:\SOFTWARE\Zabbix SIA\Zabbix Agent 2 (64-bit)\"
$zabbixAgent2Version = (Get-ItemProperty -Path $registryPath -ErrorAction SilentlyContinue).ProductVersion

# Define the minimum version to check against
$minVersion = New-Object -TypeName System.Version "7.0.1"
$isVersionOk = $false

if ($zabbixAgent2Version) {
    $currentVersion = New-Object -TypeName System.Version $zabbixAgent2Version
    $isVersionOk = $currentVersion -ge $minVersion
}

# Check if Chocolatey is installed and verify its version
try {
    $chocoVersion = choco --version
    if ($chocoVersion -lt '2.3.0') {
        Write-Host "Chocolatey version is lower than 2.3.0. Upgrading Chocolatey..."
        choco upgrade chocolatey -y
    }
}
catch {
    Write-Host "Chocolatey is not installed. Installing Chocolatey..."
    # Check if running as Administrator
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This script requires Administrator privileges."
        # Optionally, exit or prompt for elevation
    }
    else {
        # Assuming choco-install.ps1 is in the C:\scripts directory
        $scriptPath = "C:\scripts\choco-install.ps1"
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs -Wait
    }
}

if ($isVersionOk) {
    Write-Host "Zabbix Agent 2 version is $zabbixAgent2Version. No need to remove or reinstall."
}
else {
    # Proceed with the removal and installation script
    # Define the names of the services and the display names of the programs as they appear in "Programs and Features"
    $services = @("Zabbix Agent", "Zabbix Agent 2")
    $programs = @("Zabbix Agent", "Zabbix Agent 2")

    # Check and stop services if they are running
    foreach ($service in $services) {
        $serviceStatus = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($serviceStatus) {
            Write-Host "Service $service is installed. Checking status..."
            if ($serviceStatus.Status -eq 'Running') {
                Write-Host "Service $service is running. Attempting to stop..."
                Stop-Service -Name $service -Force
                Write-Host "Service $service stopped."
            }
        }
    }

    # Uninstall the programs
    foreach ($program in $programs) {
        $app = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match $program }
        if ($app) {
            Write-Host "Uninstalling $program..."
            $app.Uninstall()
            Write-Host "$program uninstalled."
        }
        else {
            Write-Host "$program is not installed."
        }
    }

    Write-Host "Remove completed."

    # Install Zabbix Agent 2
    $params = '"/SERVER:zabbix.hartphp.com.pl,zabbix-new.hartphp.com.pl /SERVERACTIVE:zabbix.hartphp.com.pl,zabbix-new.hartphp.com.pl /HOSTNAME:' + $env:COMPUTERNAME + '"'
    choco install zabbix-agent2 --force -y --params $params
}

Write-Host "Zabbix Agent 2 installation completed."