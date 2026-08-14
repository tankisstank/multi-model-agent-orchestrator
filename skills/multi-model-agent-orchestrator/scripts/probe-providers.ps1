#requires -Version 7.0
[CmdletBinding()]
param([string[]]$Provider = @('codex', 'claude', 'grok', 'gemini'))

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$profiles = @{
    codex  = @{ non_interactive = $true;  resume = $true;  hooks = $false; tier = 1 }
    claude = @{ non_interactive = $true;  resume = $true;  hooks = $true;  tier = 1 }
    grok   = @{ non_interactive = $false; resume = $false; hooks = $false; tier = 0 }
    gemini = @{ non_interactive = $true;  resume = $true;  hooks = $true;  tier = 1 }
}

$Provider | ForEach-Object {
    $name = $_.ToLowerInvariant()
    $commandInfo = Get-Command -Name $name -ErrorAction SilentlyContinue | Select-Object -First 1
    $profile = $profiles[$name]
    if ($null -eq $profile) { $profile = @{ non_interactive = $false; resume = $false; hooks = $false; tier = 0 } }
    [PSCustomObject]@{
        provider = $name
        installed = ($null -ne $commandInfo)
        command = if ($null -ne $commandInfo) { $commandInfo.Source } else { $null }
        capability_status = 'conservative profile; verify CLI help before dispatch'
        non_interactive = [bool]$profile.non_interactive
        structured_output = $false
        resume = [bool]$profile.resume
        hooks = [bool]$profile.hooks
        integration_tier = [int]$profile.tier
    }
} | ConvertTo-Json -Depth 4
