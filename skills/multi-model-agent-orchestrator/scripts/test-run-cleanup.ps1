#requires -Version 7.0
[CmdletBinding()]
param([Parameter(Mandatory)][string]$StatePath)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $StatePath -PathType Leaf)) { throw "Run state does not exist: $StatePath" }

$state = Get-Content -Raw -LiteralPath $StatePath | ConvertFrom-Json -Depth 30
$resources = if ($null -eq $state.PSObject.Properties['resources']) { @() } else { @($state.resources) }
$unresolvedStates = @('active', 'orphaned', 'cleaning', 'blocked')
$unresolved = @($resources | Where-Object { $_.status -in $unresolvedStates })
$preserved = @($resources | Where-Object { $_.status -eq 'preserved' })
$missing = @($resources | Where-Object { $_.status -eq 'not-found' })

[PSCustomObject]@{
    valid = ($unresolved.Count -eq 0)
    run_id = $state.id
    resource_count = $resources.Count
    unresolved = @($unresolved | Select-Object id, kind, status, work_package_id)
    preserved = @($preserved | Select-Object id, kind, status, work_package_id)
    not_found = @($missing | Select-Object id, kind, status, work_package_id)
} | ConvertTo-Json -Depth 8

if ($unresolved.Count -gt 0) { exit 1 }
