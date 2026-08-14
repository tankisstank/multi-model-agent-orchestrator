#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$Objective,
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]{0,62}$')][string]$RunId,
    [ValidateSet('plan', 'execute', 'audit', 'resume')][string]$Mode = 'plan',
    [ValidateSet('S0', 'S1', 'S2', 'S3')][string]$Scale = 'S1',
    [string]$StateDirectory = (Join-Path ([System.IO.Path]::GetTempPath()) 'multi-model-agent-orchestrator')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $StateDirectory) -and $PSCmdlet.ShouldProcess($StateDirectory, 'Create run-state directory')) {
    New-Item -ItemType Directory -Path $StateDirectory -Force | Out-Null
}
$statePath = Join-Path $StateDirectory "$RunId.json"
if (Test-Path -LiteralPath $statePath) { throw "Run state already exists: $statePath" }
$now = [DateTime]::UtcNow.ToString('o')
$state = [ordered]@{
    id = $RunId; objective = $Objective; mode = $Mode; scale = $Scale; status = 'planned'
    created_at = $now; updated_at = $now; projects = @(); work_packages = @(); approvals = @(); evidence = @()
    orchestration = [ordered]@{ backend = $null; herdr = $null; native_subagents = $null }
    resources = @()
    cleanup = [ordered]@{ status = 'pending'; started_at = $null; completed_at = $null; results = @() }
    events = @([ordered]@{ time = $now; event = 'run-created'; actor = 'leader' })
    budget = [ordered]@{ max_workers = 3; max_parallel = 3; max_attempts_per_wp = 3; max_review_rounds = 2 }
}
if ($PSCmdlet.ShouldProcess($statePath, 'Write initial run state')) {
    $state | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $statePath -Encoding utf8NoBOM
}
[PSCustomObject]@{ run_id = $RunId; state_path = $statePath; status = 'planned' } | ConvertTo-Json
