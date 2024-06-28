<#
.SYNOPSIS
    Module to import system performance scripts.

.DESCRIPTION
    This module imports a series of PowerShell functions designed to gather system performance metrics. 
    It facilitates easy access to functions for measuring CPU, RAM, disk, and network usage as well as system uptime.

.EXAMPLE
    Import-Module .\SystemPerformanceInfo.psm1
    This will import the module and make all the performance functions available for use.

.NOTES
    Version      : 1.0
    Author       : emilio.gives
    Company      : emilio.gives
    Last Modified: 15/06/2024
    Project Site : https://github.com/emiliogives/PSSystemPerformanceInfo
    Dependencies : Windows Management Instrumentation (WMI)

#>

#Get public and private function definition files.
$public  = @( Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 -ErrorAction SilentlyContinue )
$functions = @()

foreach($import in $public){
    try
    {
        . $import.fullname

        $scriptFunctions = Get-Command $import.fullname
        $functionNames = $scriptFunctions.ScriptBlock.Ast.FindAll(
            { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false).Name

        $functions += $functionNames
    }
    catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

foreach($function in $functions){
    Export-ModuleMember -Function $function
}