# Windows Assessment Script
# Get system information
$osInfo = Get-CimInstance Win32_OperatingSystem
$compInfo = Get-CimInstance Win32_ComputerSystem
$procInfo = Get-CimInstance Win32_Processor
$memInfo = Get-CimInstance Win32_PhysicalMemory

# Calculate total memory capacity (sum of all physical memory modules)
$totalMemoryGB = 0
foreach ($module in $memInfo) {
    $totalMemoryGB += $module.Capacity / 1GB
}

# Display system information
$systemInfoArt = @"

__      __  ____              .__    ________         __    
/  \    /  \/_   | ____   ____ |  |__ \_____  \  ____ |  | __
\   \/\/   / |   |/    \_/ ___\|  |  \  _(__  <_/ ___\|  |/ /
 \        /  |   |   |  \  \___|   Y  \/       \  \___|    < 
  \__/\  /   |___|___|  /\___  >___|  /______  /\___  >__|_ \
       \/             \/     \/     \/       \/     \/     \/
                                                      
"@
Write-Host $systemInfoArt
Write-Host "Operating System: $($osInfo.Caption) $($osInfo.Version)"
Write-Host "Computer Name: $($compInfo.Name)"
Write-Host "Manufacturer: $($compInfo.Manufacturer)"
Write-Host "Model: $($compInfo.Model)"
Write-Host "Processor: $($procInfo.Name)"
Write-Host "Processor Cores: $($procInfo.NumberOfCores)"
Write-Host "Total Memory (GB): $([math]::Round($totalMemoryGB, 2))"

# Check for installed software
$installedSoftware = Get-WmiObject -Class Win32_Product
Write-Host ""
Write-Host "Installed Software:"
Write-Host "-----------------------------------"
foreach ($software in $installedSoftware) {
    Write-Host "$($software.Name) - Version $($software.Version)"
}

# Check for open network ports
$openPorts = Test-NetConnection -ComputerName localhost
Write-Host ""
Write-Host "Open Network Ports:"
Write-Host "-----------------------------------"
$openPorts | ForEach-Object {
    Write-Host "Port $($_.RemotePort) is $($_.TcpTestSucceeded)"
}

# Check for Windows updates
$windowsUpdates = Get-HotFix
Write-Host ""
Write-Host "Installed Windows Updates:"
Write-Host "-----------------------------------"
$windowsUpdates | ForEach-Object {
    Write-Host "$($_.Description) - Installed on $($_.InstalledOn)"
}

# Check for running processes
$runningProcesses = Get-Process
Write-Host ""
Write-Host "Running Processes:"
Write-Host "-----------------------------------"
$runningProcesses | ForEach-Object {
    Write-Host "$($_.Name) - ID: $($_.Id) - CPU Usage: $($_.CPUUsage) %"
}

# Disk Space Information
$diskInfo = Get-CimInstance Win32_LogicalDisk
Write-Host ""
Write-Host "Disk Space Information:"
Write-Host "-----------------------------------"
foreach ($disk in $diskInfo) {
    $diskSizeGB = $disk.Size / 1GB
    $diskFreeSpaceGB = $disk.FreeSpace / 1GB
    Write-Host "Drive $($disk.DeviceID):"
    Write-Host "   Total Space (GB): $([math]::Round($diskSizeGB, 2))"
    Write-Host "   Free Space (GB): $([math]::Round($diskFreeSpaceGB, 2))"
}

# Network Configuration
$networkAdapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }
Write-Host ""
Write-Host "Network Configuration:"
Write-Host "-----------------------------------"
foreach ($adapter in $networkAdapters) {
    Write-Host "Adapter: $($adapter.Description)"
    Write-Host "   IP Address(es): $($adapter.IPAddress -join ', ')"
    Write-Host "   Subnet Mask(s): $($adapter.IPSubnet -join ', ')"
}

# # Installed Windows Features
# $installedFeatures = Get-WindowsFeature
# Write-Host ""
# Write-Host "Installed Windows Features and Roles:"
# Write-Host "-----------------------------------"
# $installedFeatures | Where-Object { $_.Installed } | ForEach-Object {
#     Write-Host "$($_.Name)"
# }

# Recent Event Log Entries
$eventLogs = Get-WinEvent -LogName Application, System -MaxEvents 10 | Sort-Object TimeCreated -Descending
Write-Host ""
Write-Host "Recent Event Log Entries:"
Write-Host "-----------------------------------"
foreach ($event in $eventLogs) {
    Write-Host "Log: $($event.LogName)"
    Write-Host "   Source: $($event.ProviderName)"
    Write-Host "   Event ID: $($event.Id)"
    Write-Host "   Time: $($event.TimeCreated)"
    Write-Host "   Message: $($event.Message)"
}
