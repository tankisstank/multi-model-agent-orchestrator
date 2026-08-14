#requires -Version 7.0
[CmdletBinding()]
param(
    [switch]$NativeSubagentsAvailable,
    [string]$HerdrSkillPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$herdrCommand = Get-Command -Name 'herdr' -ErrorAction SilentlyContinue | Select-Object -First 1
$insideHerdr = $env:HERDR_ENV -eq '1'
$userProfile = [Environment]::GetFolderPath('UserProfile')
$skillCandidates = [System.Collections.Generic.List[string]]::new()
if (-not [string]::IsNullOrWhiteSpace($HerdrSkillPath)) { $skillCandidates.Add($HerdrSkillPath) }
if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) { $skillCandidates.Add((Join-Path $env:CODEX_HOME 'skills\herdr\SKILL.md')) }
$skillCandidates.Add((Join-Path $userProfile '.codex\skills\herdr\SKILL.md'))
$skillCandidates.Add((Join-Path $userProfile '.agents\skills\herdr\SKILL.md'))
$skillAvailable = @($skillCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }).Count -gt 0

$selected = if ($insideHerdr -and $null -ne $herdrCommand -and $skillAvailable) {
    'herdr'
} elseif ($NativeSubagentsAvailable) {
    'codex-native'
} else {
    'direct-cli-after-probe'
}

$recommendations = [System.Collections.Generic.List[string]]::new()
if ($null -eq $herdrCommand) {
    $recommendations.Add('Install Herdr, then launch or attach the Codex session inside Herdr.')
}
if (-not $skillAvailable) {
    $recommendations.Add('Install or expose the herdr skill to Codex before using Herdr orchestration.')
}
if ($null -ne $herdrCommand -and -not $insideHerdr) {
    $recommendations.Add('Herdr is installed but inactive. Do not control panes from outside; launch or attach through Herdr.')
}
if ($selected -eq 'direct-cli-after-probe') {
    $recommendations.Add('Run probe-providers.ps1 and inspect the selected CLI help before dispatch.')
}

[PSCustomObject]@{
    selected = $selected
    herdr = [ordered]@{
        installed = ($null -ne $herdrCommand)
        active = $insideHerdr
        command = if ($null -ne $herdrCommand) { $herdrCommand.Source } else { $null }
        skill_available = [bool]$skillAvailable
    }
    native_subagents_available = [bool]$NativeSubagentsAvailable
    recommendations = @($recommendations)
} | ConvertTo-Json -Depth 5
