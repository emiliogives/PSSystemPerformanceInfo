# PSSystemPerformanceInfo

[![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/emiliogives/PSSystemPerformanceInfo)

## Overview

PSSystemPerformanceInfo is a PowerShell module that provides detailed network and system performance metrics. This module includes functions to test network speeds, gather comprehensive system information, and monitor system performance metrics such as CPU usage, RAM usage, disk usage, network statistics, and system uptime.

## Installation

Clone the repository to your local machine:

```powershell
git clone https://github.com/emiliogives/PSSystemPerformanceInfo
```

Import the module:

```powershell
Import-Module .\PSSystemPerformanceInfo.psm1
```

## Functions

### Test-NetworkSpeed

**Description:** Downloads and executes the Speedtest CLI to measure network speeds and gathers network-related information.

**Usage:**

```powershell
Test-NetworkSpeed
```

### Get-SystemInfoSummary

**Description:** Collects and summarizes system hardware information, including CPU, GPU, RAM, and storage details.

**Usage:**

```powershell
Get-SystemInfoSummary
```

### Get-CpuUsagePercentage

**Description:** Returns the current CPU usage as a percentage.

**Usage:**

```powershell
Get-CpuUsagePercentage
```

### Get-RamUsagePercentage

**Description:** Returns the current RAM usage as a percentage.

**Usage:**

```powershell
Get-RamUsagePercentage
```

### Get-DisksUsedCapacity

**Description:** Returns the usage capacity of each physical disk as a percentage.

**Usage:**

```powershell
Get-DisksUsedCapacity
```

### Get-DiskReadByteRate

**Description:** Returns the rate of reading data from the disk in bytes per second.

**Usage:**

```powershell
Get-DiskReadByteRate
```

### Get-DiskWriteByteRate

**Description:** Returns the rate of writing data to the disk in bytes per second.

**Usage:**

```powershell
Get-DiskWriteByteRate
```

### Get-NetworkInByteRate

**Description:** Returns the current network inbound rate in bytes per second.

**Usage:**

```powershell
Get-NetworkInByteRate
```

### Get-NetworkOutByteRate

**Description:** Returns the current network outbound rate in bytes per second.

**Usage:**

```powershell
Get-NetworkOutByteRate
```

### Get-NetworkUsagePercentage

**Description:** Returns the average network usage as a percentage over a specified period.

**Usage:**

```powershell
Get-NetworkUsagePercentage
```

### Get-UpTimeMinutes

**Description:** Returns the system uptime in minutes.

**Usage:**

```powershell
Get-UpTimeMinutes
```

### Get-SystemStats

**Description:** Aggregates all collected metrics into a single object with detailed system performance statistics.

**Usage:**

```powershell
Get-SystemStats
```

## Notes

- **Version:** 1.0
- **Author:** emilio.gives
- **Company:** emilio.gives
- **Last Modified:** 15/06/2024
- **Project Site:** [GitHub](https://github.com/emiliogives/PSSystemPerformanceInfo)
- **Dependencies:** Windows Management Instrumentation (WMI)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

Special thanks to all contributors and the PowerShell community.

The speed test functionality uses [asheroto/speedtest](https://github.com/asheroto/speedtest) for the internet speed test functionality.
