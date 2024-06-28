<#PSScriptInfo

.VERSION 1.0
.GUID 4ddb67eb-9437-4e25-b68d-02a039e72285
.AUTHOR emilio.gives
.COMPANYNAME emilio.gives
.TAGS PowerShell Network SpeedTest SystemInfoSummary
.PROJECTURI https://github.com/emiliogives/PSSystemPerformanceInfo
.RELEASENOTES
[Version 1.0] - Initial Release. Provides detailed network and system information.

#>

<#
.SYNOPSIS
    Tests the network speed and gathers comprehensive system information.

.DESCRIPTION
    This script automates the process of downloading and running 
    the Speedtest.net CLI tool, and then collects detailed system 
    information including CPU, GPU, and memory stats. 
    
    It uses `Test-NetworkSpeed` to check the network speeds 
    and `Get-SystemInfoSummary` to collect and summarize system 
    hardware information.

.EXAMPLE
    .\SystemInfo.ps1
    This will import the script and make available the
    `Test-NetworkSpeed` and `Get-SystemInfoSummary`a functions

.PARAMETER No parameters
    This script does not accept parameters.

.NOTES
    Version      : 1.0
    Created by   : emilio.gives
    Last Modified: 15/06/2024
    Dependencies : Speedtest CLI, PowerShell 5.1 or higher

.LINK
    Project Site: https://github.com/emilio.gives/PowerShellSystemPerformanceInfo

.FUNCTIONS
    Test-NetworkSpeed
        Description: Downloads and executes the Speedtest CLI to measure network speeds and gathers network-related information.

    Get-SystemInfoSummary
        Description: Collects and summarizes system hardware information, including CPU, GPU, RAM, and storage details.
#>



function Test-NetworkSpeed{
    $speedTestAgent = "$($env:TEMP)\Speedtest\speedtest.exe"

    if (!(Test-Path $speedTestAgent)) {
        $downloadPath = "$($env:TEMP)\SpeedTest.zip" 
        $url = "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip"

        Invoke-WebRequest -Uri $url -OutFile $downloadPath 
        Expand-Archive $downloadPath -DestinationPath "$($env:TEMP)\Speedtest" -Force
    }
    
    $test = Invoke-Expression "$speedTestAgent --accept-license"
    
    $downloadSpeed = [regex]::match(($test | where-object { $_ -like "*Download:*" }).trim(), '[0-9]+\.?[0-9]*').value
    $uploadSpeed = [regex]::match(($test | where-object { $_ -like "*Upload:*" }).trim(), '[0-9]+\.?[0-9]*').value
    $isp = ($test | where-object { $_ -like "*ISP:*" }).trim().split(":")[1].trim()
    $server = ($test | where-object { $_ -like "*Server:*" }).trim().split(":")[1].trim()
    $speedTestURL = ($test | where-object { $_ -like "*Result URL:*" }).trim().split(" ")[2].trim()
    
    $results = [PSCustomObject]@{
        Server     = $server
        ISP        = $isp
        Download   = $downloadSpeed
        Upload     = $uploadSpeed
        ResultsURL = $speedTestURL
    }

    return $results
}

function Get-SystemInfoSummary{
    $computerSystem = Get-CimInstance CIM_ComputerSystem
    $operatingSystem = Get-CimInstance CIM_OperatingSystem
    $processors = Get-CimInstance CIM_Processor
    $videoControllers = Get-CimInstance CIM_VideoController
    $physicalMemory = Get-CimInstance CIM_PhysicalMemory
    $bios = Get-WmiObject Win32_BIOS
    $logicalDisks = Get-WmiObject Win32_LogicalDisk

    $gpuSummary = $videoControllers | ForEach-Object {
        "GPU $($_.Name): VRAM $([Math]::Round($_.AdapterRAM / 1GB, 2))GB"
    } | Out-String -Stream
    
    $diskSummary = $logicalDisks | ForEach-Object {
        "Disk $($_.DeviceID -replace '.*(\w):','$1'): $([Math]::Round($_.Size / 1GB, 2))GB"
    } | Out-String -Stream
    
    $cpuSummary = $processors | Group-Object Name | ForEach-Object {
        "$($_.Count)CPUs $($_.Name)"
    } | Out-String -Stream
    
    $physicalMemory = "{0} GB" -f [Math]::Round(($physicalMemory | Measure-Object Capacity -Sum).Sum / 1GB, 2)

    $speedTest = Test-NetworkSpeed

    $systemInfo = [PSCustomObject]@{
        DeviceName = $computerSystem.Name
        SerialNumber = $bios.SerialNumber
        OperatingSystem = $operatingSystem.Caption
        Cpu = $cpuSummary -join ", "
        Gpu = $gpuSummary -join ", "
        PhysicalMemory = $physicalMemory
        Model = $computerSystem.Model
        Manufacturer = $computerSystem.Manufacturer
        SystemArchitecture = $computerSystem.SystemType
        Biosversion = $bios.SMBIOSBIOSVersion
        HardDrives = $diskSummary
        UploadSpeedMBs = $speedTest.Upload
        DownloadSpeedMBs = $speedTest.Download
    }

    return $systemInfo
}