#requires -Version 7.0
[CmdletBinding()]
param([Parameter(Mandatory, ValueFromPipeline)][string]$Path)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Worker report does not exist: $Path" }
try { $report = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json -Depth 20 }
catch { throw "Worker report is not valid JSON: $Path. $($_.Exception.Message)" }

$errors = [System.Collections.Generic.List[string]]::new()
if ($report.status -notin @('ready-for-review', 'blocked', 'failed')) { $errors.Add('invalid status') }
foreach ($name in @('summary', 'project', 'files_changed', 'commands_run', 'checks', 'data_impact', 'evidence', 'residual_risks', 'uncertainties')) {
    if ($null -eq $report.PSObject.Properties[$name]) { $errors.Add("missing required property: $name") }
}
foreach ($item in @($report.commands_run)) {
    if ($null -ne $item -and ($null -eq $item.command -or $null -eq $item.exit_code -or $item.result -notin @('pass', 'fail', 'skipped'))) {
        $errors.Add('invalid commands_run item'); break
    }
}
[PSCustomObject]@{ valid = ($errors.Count -eq 0); status = $report.status; errors = @($errors); report_path = (Resolve-Path -LiteralPath $Path).Path } | ConvertTo-Json -Depth 5
if ($errors.Count -gt 0) { exit 1 }
