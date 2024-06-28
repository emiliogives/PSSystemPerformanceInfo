<#PSScriptInfo

.VERSION 1.0
.GUID b914cbd5-fa58-4e4f-b142-c1e302def505
.AUTHOR emilio.gives
.COMPANYNAME emilio.gives
.TAGS PowerShell SystemStats CpuUsage RamUsage DiskUsage NetworkStats
.PROJECTURI https://github.com/emiliogives/PSSystemPerformanceInfo
.RELEASENOTES
[Version 1.0] - Initial Release. Provides detailed system performance metrics.

#>

<#
.SYNOPSIS
    Collects detailed system performance metrics.

.DESCRIPTION
    This script provides an overview of various system performance metrics 
    such as CPU usage, RAM usage, disk usage, network statistics, and system uptime. 
    It uses multiple PowerShell functions to gather specific metrics, 
    which are then aggregated into a comprehensive system statistics object.

.EXAMPLE
    .\SystemMetrics.ps1
    This will import the script and make available the functions:
    - Get-CpuUsagePercentage: Returns the current CPU usage as a percentage.
    - Get-RamUsagePercentage: Returns the current RAM usage as a percentage.
    - Get-DisksUsedCapacity: Returns the usage capacity of each physical disk as a percentage.
    - Get-DiskReadByteRate: Returns the rate of reading data from the disk in bytes per second.
    - Get-DiskWriteByteRate: Returns the rate of writing data to the disk in bytes per second.
    - Get-NetworkInByteRate: Returns the current network inbound rate in bytes per second.
    - Get-NetworkOutByteRate: Returns the current network outbound rate in bytes per second.
    - Get-NetworkUsagePercentage: Returns the average network usage as a percentage over a specified period.
    - Get-UpTimeMinutes: Returns the system uptime in minutes.
    - Get-SystemStats: Aggregates all collected metrics into a single object with detailed system performance statistics.

.PARAMETER No parameters
    This script does not accept parameters.

.NOTAs
    Version      : 1.0
    Created by   : emilio.gives
    Last Modified: 15/06/2024
    Dependencies : Windows Management Instrumentation (WMI)

.LINK
    Project Site: https://github.com/emilio.gives/PowerShellSystemPerformanceInfo

.FUNCTIONS
    Get-CpuUsagePercentage
        Description: Returns the current CPU usage as a percentage.

    Get-RamUsagePercentage
        Description: Returns the current RAM usage as a percentage.

    Get-DisksUsedCapacity
        Description: Returns the usage capacity of each physical disk as a percentage.

    Get-DiskReadByteRate
        Description: Returns the rate of reading data from the disk in bytes per second.

    Get-DiskWriteByteRate
        Description: Returns the rate of writing data to the disk in bytes per second.

    Get-NetworkInByteRate
        Description: Returns the current network inbound rate in bytes per second.

    Get-NetworkOutByteFrate
        Description: Returns the current network outbound rate in bytes per second.

    Get-NetworkUsagePercentage
        Description: Returns the average network usage as a percentage over a specified period.

    Get-UpTimeMinutes
        Description: Returns the system uptime in minutes.

    Get-SystemStats
        Description: Aggregates all collected metrics into a single object with detailed system performance statistics.
#>


function Get-CpuUsagePercentage {
    $timestamp = Get-Date
    $cpuLoad = (wmic cpu get loadpercentage | ?{[int]::TryParse($_, [ref]$null)} | Measure-Object -Average).Average
    $cpuUsage = [Math]::round($cpuLoad / 100, 4)

    return $cpuUsage
}

function Get-RamUsagePercentage{
    $cs = Get-CimInstance -ClassName Win32_OperatingSystem
    $totalVisibleMemory = $cs.TotalVisibleMemorySize
    $freePhysicalMemory = $cs.FreePhysicalMemory
    $usedMemory = $totalVisibleMemory - $freePhysicalMemory
    $memoryUsage = [Math]::round($usedMemory / $totalVisibleMemory, 4)

    return $memoryUsage
}

function Get-DisksUsedCapacity{
    $disksInfo = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    $disksUsage = @()

    foreach($disk in $disksInfo){
        $usedSpace = $disk.Size - $disk.FreeSpace
        $diskUsage = [Math]::round($usedSpace/$disk.Size, 4)

        $disksUsage += $diskUsage
    } 

    return $disksUsage
}

function Get-DiskReadByteRate{
    $bytesPersec =  % { (Get-WmiObject Win32_PerfRawData_PerfDisk_PhysicalDisk | Where-Object { $_.Name -like "0*"}).DiskReadBytesPersec /1024 }
    return [Math]::round($bytesPersec,0)
}

function Get-DiskWriteByteRate{
    $bytesPersec =  % { (Get-WmiObject Win32_PerfRawData_PerfDisk_PhysicalDisk | Where-Object { $_.Name -like "0*"}).DiskWriteBytesPersec /1024 }
    return [Math]::round($bytesPersec,0)
}

function Get-NetworkInByteRate{
    $bytesPersec = Get-CimInstance -ClassName Win32_PerfFormattedData_Tcpip_NetworkInterface | Select-Object Name, BytesReceivedPerSec

    return $bytesPersec.BytesReceivedPerSec
}

function Get-NetworkOutByteRate{
    $bytesPersec = Get-CimInstance -ClassName Win32_PerfFormattedData_Tcpip_NetworkInterface | Select-Object Name, BytesSentPerSec

    return $bytesPersec.BytesSentPerSec
}

function Get-NetworkUsagePercentage{
    $traceSeconds = 10
    $counter = 0

    $usedBandwidth = do {
        $counter ++
        (Get-CimInstance -Query "Select BytesTotalPersec from Win32_PerfFormattedData_Tcpip_NetworkInterface" | Select-Object BytesTotalPerSec).BytesTotalPerSec / 1Mb * 8
    } while ($counter -le $traceSeconds)
    
    $netUsage = [math]::round(($usedBandwidth | Measure-Object -Average).average, 2) / 100

    return $netUsage
}

function Get-UpTimeMinutes{
    $upTimeInfo = (Get-Date)-(gcim Win32_OperatingSystem). LastBootUpTime

    return [math]::round($uptimeInfo.TotalMinutes, 6)
}

function Get-SystemStats{
    $disksUsage = Get-DisksUsedCapacity

    $systemStats = [PSCustomObject]@{
        CpuLoad = Get-CpuUsagePercentage
        RamUsage = Get-RamUsagePercentage
        DiskReadBytes = Get-DiskReadByteRate
        DiskWriteBytes = Get-DiskWriteByteRate
        Disk1Usage = $disksUsage[0]
        Disk2Usage = $disksUsage[1]
        Disk3Usage = $disksUsage[2]
        Disk4Usage = $disksUsage[3]
        Disk5Usage = $disksUsage[4]
        NetworkBytesSent = Get-NetworkOutByteRate 
        NetworkBytesReceived = Get-NetworkInByteRate
        NetworkUsage = Get-NetworkUsagePercentage
        UpTimeMinutes = Get-UpTimeMinutes
        Timestamp = Get-Date
    }

    return $systemStats
}