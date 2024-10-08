# Define ASCII art text
$asciiArt = @"

  ooooooo8    oooooooo8     o      oooo   oooo         oooo     oooo ooooo  oooo         oooooooooo    oooooooo8 
888         o888     88    888      8888o  88           8888o   888    888  88            888    888 o888     88 
 888oooooo  888           8  88     88 888o88           88 888o8 88      888              888oooo88  888         
        888 888o     oo  8oooo88    88   8888           88  888  88      888              888        888o     oo 
o88oooo888   888oooo88 o88o  o888o o88o    88          o88o  8  o88o    o888o            o888o        888oooo88   
"@

$githubText = @"

    GitHub: ArtemKech
    GitHub: DeadDove13
"@
$description = @"

This script gathers and writes detailed system information to a file, 
including PC, CPU, GPU, motherboard, storage, RAM, USB devices, network drives, and installed applications.

"@
# Define the global variable for error message color
$ErrorColour = "Red"  
$PassColour = "Green"  

# Function to run the main part of the script
function Main {
    # Define the output path on the Desktop
    $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'))
    # Define the hostname of the user
    $hostname = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name -replace '^[^\\]*\\', ''

    # Create the PCScan folder on the Desktop
    $pcScanFolderPath = $desktopPath + "\$hostname PCScan"
    if (-not (Test-Path $pcScanFolderPath)) {
        $null = New-Item -ItemType Directory -Path $pcScanFolderPath -Force
    }

    # Path for system info file inside the PCScan folder
    $outputFilePath = $pcScanFolderPath + "\system_info.txt"

    # Initialize the output file with UTF-8 encoding
    Set-Content -Path $outputFilePath -Value "" -Encoding UTF8

    # Collect and write system information
    # PC Info
    $serialNumber = (Get-WmiObject -Class Win32_BIOS).SerialNumber
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $registeredUser = $os.RegisteredUser
    $OSarchitecture = (Get-CimInstance Win32_operatingsystem).OSArchitecture
    $computerModel = (Get-CimInstance Win32_ComputerSystem).Model

    $output = @"
------------------------------------------------------------------------------------------------------------------------
PC Info:
------------------------------------------------------------------------------------------------------------------------
Hostname: $hostname
Serial Number: $serialNumber
Computer Model: $computerModel
Registered User: $registeredUser
Operating System: $($os.Caption)
OS Version: $($os.Version)
Build Number: $($os.BuildNumber)
OS Architecture: $OSarchitecture

"@

    $output | Out-File -FilePath $outputFilePath -Append -Encoding UTF8

    # CPU Info
    $cpu = Get-WmiObject Win32_Processor
    foreach ($processor in $cpu) {
        $cpuInfo = @"
------------------------------------------------------------------------------------------------------------------------
CPU Info:
------------------------------------------------------------------------------------------------------------------------
Name: $($processor.Name)
Manufacturer: $($processor.Manufacturer)
Description: $($processor.Description)
Number of Cores: $($processor.NumberOfCores)
Number of Logical Processors: $($processor.NumberOfLogicalProcessors)
Max Clock Speed: $($processor.MaxClockSpeed) MHz

"@
        $cpuInfo | Out-File -FilePath $outputFilePath -Append -Encoding UTF8
    }

# GPU Info
$gpus = Get-CimInstance Win32_VideoController

# Initialize an array to store GPU information
$gpuInfos = @()

# Loop through each GPU and process information
foreach ($gpu in $gpus) {
    # Check if the GPU is an Intel or NVIDIA GPU
    if ($gpu.Name -ilike "*NVIDIA*") {
        $qwMemorySize = (Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*" -Name HardwareInformation.qwMemorySize -ErrorAction SilentlyContinue)."HardwareInformation.qwMemorySize"
    }
    elseif ($gpu.Name -ilike "*Intel*") {
        $qwMemorySize = $gpu.AdapterRam
    }
    else {
        # Skip DisplayLink and other non-target GPUs
        continue
    }

    if ($qwMemorySize) {
        # Ensure $qwMemorySize is a number before division
        $VRAM = [math]::round($qwMemorySize / 1GB)
    } else {
        $VRAM = "N/A"
    }

    # Create GPU info string
    $gpuInfo = @"
------------------------------------------------------------------------------------------------------------------------
GPU Info:
------------------------------------------------------------------------------------------------------------------------
Manufacturer: $($gpu.AdapterCompatibility)
Model: $($gpu.Name)
VRAM: $VRAM GB

"@

    # Add GPU info to the array
    $gpuInfos += $gpuInfo
}

# Output all GPU information to file
$gpuInfos | Out-File -FilePath $outputFilePath -Append -Encoding UTF8

    # Motherboard Info
    $motherboard = Get-WmiObject Win32_BaseBoard
    $motherboardInfo = @"
------------------------------------------------------------------------------------------------------------------------
Motherboard Info:
------------------------------------------------------------------------------------------------------------------------
Manufacturer: $($motherboard.Manufacturer)
Model: $($motherboard.Product)
Serial Number: $($motherboard.SerialNumber)
Version: $($motherboard.Version)

"@
    $motherboardInfo | Out-File -FilePath $outputFilePath -Append -Encoding UTF8

    # Storage Info
    $diskDrives = Get-WmiObject Win32_DiskDrive
    $storageInfo = @"
------------------------------------------------------------------------------------------------------------------------
Storage Info:
------------------------------------------------------------------------------------------------------------------------

"@
    foreach ($disk in $diskDrives) {
        $storageInfo += @"
Model: $($disk.Model)
Size: $([math]::round($disk.Size / 1GB, 2)) GB
Serial Number: $($disk.SerialNumber)
Interface Type: $($disk.InterfaceType)

"@
    }
    $storageInfo | Out-File -FilePath $outputFilePath -Append -Encoding UTF8

    # RAM Info
    $ramModules = Get-WmiObject Win32_PhysicalMemory
    $totalCapacity = 0
    foreach ($module in $ramModules) {
        $totalCapacity += $module.Capacity
    }
    $totalCapacityGB = [math]::round($totalCapacity / 1GB, 2)
    $firstModule = $ramModules | Select-Object -First 1
    $ramInfo = @"
------------------------------------------------------------------------------------------------------------------------
RAM Info:
------------------------------------------------------------------------------------------------------------------------
Total Capacity: $totalCapacityGB GB
Speed: $($firstModule.Speed) MHz
Manufacturer: $($firstModule.Manufacturer)
SerialNumber: $($firstModule.SerialNumber)

"@
    $ramInfo | Out-File -FilePath $outputFilePath -Append -Encoding UTF8

    # USB Devices Info
    $deviceCount = 1
    $pnpUsbDevices = Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    foreach ($pnpDevice in $pnpUsbDevices) {
        if ($pnpDevice.PNPClass -ne $null) {
            $deviceInfo = @"
------------------------------------------------------------------------------------------------------------------------
USB Device #$deviceCount Info:
------------------------------------------------------------------------------------------------------------------------
Name: $($pnpDevice.FriendlyName)
PNPClass: $($pnpDevice.PNPClass)

"@
            $deviceInfo | Out-File -FilePath $outputFilePath -Append -Encoding UTF8
            $deviceCount++
        }
    }

    # Mapped Network Drives Info
    $mappedDrives = Get-WmiObject -Query "SELECT * FROM Win32_NetworkConnection"

    $networkDriveInfo = @"
------------------------------------------------------------------------------------------------------------------------
Mapped Network Drives Info:
------------------------------------------------------------------------------------------------------------------------

"@
    foreach ($drive in $mappedDrives) {
        $networkDriveInfo += @"
Local Name: $($drive.LocalName)
Remote Path: $($drive.RemoteName)
Description: $($drive.Description)
Status: $($drive.Status)

"@
    }
    $networkDriveInfo | Out-File -FilePath $outputFilePath -Append -Encoding UTF8

    # Installed Applications
    $appInfo = @"
------------------------------------------------------------------------------------------------------------------------
Installed Applications:
------------------------------------------------------------------------------------------------------------------------
"@

    $appInfo | Out-File -FilePath $outputFilePath -Append -Encoding UTF8

    # Installed Applications Collection
    $installedApps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object { $_.DisplayName } | 
    Select-Object @{Name = 'Application'; Expression = { $_.DisplayName } }, @{Name = 'Version'; Expression = { $_.DisplayVersion } }, Publisher

    $formattedOutput = $installedApps | Format-Table -Property Application, Version, Publisher -AutoSize | Out-String
    $formattedOutput | Out-File -FilePath $outputFilePath -Append -Encoding UTF8

    Write-Host "System information and installed applications have been written to $outputFilePath `n" -ForegroundColor $PassColour
}

# Display ASCII art and GitHub information
Write-Host $asciiArt -ForegroundColor Green
Write-Host $githubText -ForegroundColor White
Write-Host $description -ForegroundColor Yellow

# Prompt the user to press 1 to run the script or 0 to close
do {
    $choice = Read-Host "Press 1 to run the script or 0 to close"

    # Execute based on user's choice
    if ($choice -eq "1") {
        Main
        break
    }
    elseif ($choice -eq "0") {
        Write-Host "Exiting the script." -ForegroundColor White
        Exit
    }
    else {
        Write-Host "B R U H!!! Invalid input. Please try again." -ForegroundColor $ErrorColour
    }
} while ($true)

# Wait for the user to press a key before exiting
Read-Host -Prompt "Press Enter to exit"
