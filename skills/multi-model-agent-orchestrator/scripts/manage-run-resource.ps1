#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$StatePath,
    [Parameter(Mandatory)][ValidateSet('register', 'set-status')][string]$Action,
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$')][string]$ResourceId,
    [ValidateSet('herdr-pane', 'herdr-tab', 'herdr-workspace', 'native-agent', 'process', 'playwright', 'temp-path', 'worktree')][string]$Kind,
    [string]$WorkPackageId,
    [string]$LocatorJson = '{}',
    [ValidateSet('auto', 'approval', 'preserve')][string]$CleanupPolicy = 'auto',
    [ValidateSet('active', 'orphaned', 'cleaning', 'cleaned', 'preserved', 'blocked', 'not-found')][string]$Status = 'active',
    [string]$Result
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $StatePath -PathType Leaf)) { throw "Run state does not exist: $StatePath" }

$state = Get-Content -Raw -LiteralPath $StatePath | ConvertFrom-Json -Depth 30
if ($null -eq $state.PSObject.Properties['resources']) {
    $state | Add-Member -NotePropertyName resources -NotePropertyValue @()
}
$resources = [System.Collections.Generic.List[object]]::new()
foreach ($resource in @($state.resources)) { $resources.Add($resource) }
$existing = @($resources | Where-Object { $_.id -eq $ResourceId })
$now = [DateTime]::UtcNow.ToString('o')

if ($Action -eq 'register') {
    if ([string]::IsNullOrWhiteSpace($Kind)) { throw 'Kind is required when registering a resource.' }
    if ($existing.Count -gt 0) { throw "Resource already exists: $ResourceId" }
    try { $locator = $LocatorJson | ConvertFrom-Json -Depth 20 }
    catch { throw "LocatorJson is not valid JSON. $($_.Exception.Message)" }
    $resources.Add([PSCustomObject][ordered]@{
        id = $ResourceId
        kind = $Kind
        owner_run_id = $state.id
        work_package_id = $WorkPackageId
        created_by_run = $true
        locator = $locator
        status = 'active'
        registered_at = $now
        cleanup = [PSCustomObject][ordered]@{ policy = $CleanupPolicy; result = $null; updated_at = $null }
    })
} else {
    if ($existing.Count -ne 1) { throw "Expected exactly one resource named $ResourceId; found $($existing.Count)." }
    $resource = $existing[0]
    $resource.status = $Status
    $resource.cleanup.result = $Result
    $resource.cleanup.updated_at = $now
}

$state.resources = @($resources)
$state.updated_at = $now
$stateDirectory = Split-Path -Parent (Resolve-Path -LiteralPath $StatePath).Path
$temporaryPath = Join-Path $stateDirectory ".$([IO.Path]::GetFileName($StatePath)).$PID.tmp"
if ($PSCmdlet.ShouldProcess($StatePath, "$Action resource $ResourceId")) {
    try {
        $state | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $temporaryPath -Encoding utf8NoBOM
        Move-Item -LiteralPath $temporaryPath -Destination $StatePath -Force
    } finally {
        if (Test-Path -LiteralPath $temporaryPath) { Remove-Item -LiteralPath $temporaryPath -Force }
    }
}

[PSCustomObject]@{ run_id = $state.id; resource_id = $ResourceId; action = $Action; status = if ($Action -eq 'register') { 'active' } else { $Status } } | ConvertTo-Json
