#requires -Version 7.0
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$plugin = Join-Path $root '.codex-plugin\plugin.json'
$skill = Join-Path $root 'skills\multi-model-agent-orchestrator\SKILL.md'
$probe = Join-Path $root 'skills\multi-model-agent-orchestrator\scripts\probe-providers.ps1'
$backend = Join-Path $root 'skills\multi-model-agent-orchestrator\scripts\select-agent-backend.ps1'
$lifecycle = Join-Path $root 'skills\multi-model-agent-orchestrator\references\resource-lifecycle.md'
$resourceManager = Join-Path $root 'skills\multi-model-agent-orchestrator\scripts\manage-run-resource.ps1'
$cleanupTest = Join-Path $root 'skills\multi-model-agent-orchestrator\scripts\test-run-cleanup.ps1'
$workspaceSelection = Join-Path $root 'skills\multi-model-agent-orchestrator\references\workspace-selection.md'

if (-not (Test-Path -LiteralPath $plugin -PathType Leaf)) { throw "Missing plugin manifest: $plugin" }
if (-not (Test-Path -LiteralPath $skill -PathType Leaf)) { throw "Missing skill: $skill" }
if (-not (Test-Path -LiteralPath $probe -PathType Leaf)) { throw "Missing provider probe: $probe" }
if (-not (Test-Path -LiteralPath $backend -PathType Leaf)) { throw "Missing backend selector: $backend" }
if (-not (Test-Path -LiteralPath $lifecycle -PathType Leaf)) { throw "Missing resource lifecycle contract: $lifecycle" }
if (-not (Test-Path -LiteralPath $resourceManager -PathType Leaf)) { throw "Missing resource manager: $resourceManager" }
if (-not (Test-Path -LiteralPath $cleanupTest -PathType Leaf)) { throw "Missing cleanup gate: $cleanupTest" }
if (-not (Test-Path -LiteralPath $workspaceSelection -PathType Leaf)) { throw "Missing workspace selection policy: $workspaceSelection" }

$manifest = Get-Content -Raw -LiteralPath $plugin | ConvertFrom-Json
if ($manifest.name -ne 'multi-model-agent-orchestrator') { throw 'Plugin name does not match expected name.' }
if ($manifest.skills -ne './skills/') { throw 'Plugin skills path must be ./skills/.' }

$providers = & $probe | ConvertFrom-Json
if ($providers.Count -lt 1) { throw 'Provider probe returned no providers.' }
$backendResult = & $backend -NativeSubagentsAvailable | ConvertFrom-Json
if ($backendResult.selected -notin @('herdr', 'codex-native', 'direct-cli-after-probe')) { throw 'Backend selector returned an invalid backend.' }

[PSCustomObject]@{
    valid = $true
    plugin = $manifest.name
    provider_count = $providers.Count
    selected_backend = $backendResult.selected
} | ConvertTo-Json
