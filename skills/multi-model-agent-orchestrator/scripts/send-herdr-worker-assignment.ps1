#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$PaneId,
    [Parameter(Mandatory)][string]$AssignmentPath,
    [ValidateRange(256, 16000)][int]$ChunkCharacters = 4000,
    [switch]$NoSubmit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($env:HERDR_ENV -ne '1') { throw 'Herdr dispatch requires HERDR_ENV=1.' }
if ($null -eq (Get-Command -Name 'herdr' -ErrorAction SilentlyContinue)) { throw 'The herdr command is unavailable.' }
if (-not (Test-Path -LiteralPath $AssignmentPath -PathType Leaf)) { throw "Assignment does not exist: $AssignmentPath" }

$panes = (& herdr pane list | ConvertFrom-Json -Depth 20).result.panes
$pane = @($panes | Where-Object { $_.pane_id -eq $PaneId })
if ($pane.Count -ne 1) { throw "Expected exactly one current Herdr pane named $PaneId; found $($pane.Count)." }
if ($pane[0].focused) { throw 'Refusing to send a worker assignment to the focused/leader pane.' }

$assignment = Get-Content -Raw -LiteralPath $AssignmentPath
if ([string]::IsNullOrWhiteSpace($assignment)) { throw "Assignment is empty: $AssignmentPath" }

for ($offset = 0; $offset -lt $assignment.Length; $offset += $ChunkCharacters) {
    $length = [Math]::Min($ChunkCharacters, $assignment.Length - $offset)
    $chunk = $assignment.Substring($offset, $length)
    if ($PSCmdlet.ShouldProcess($PaneId, "Send assignment characters $offset through $($offset + $length - 1)")) {
        & herdr pane send-text $PaneId $chunk
        if ($LASTEXITCODE -ne 0) { throw "Herdr failed while sending assignment chunk starting at $offset." }
    }
}
if (-not $NoSubmit -and $PSCmdlet.ShouldProcess($PaneId, 'Submit worker assignment')) {
    & herdr pane send-keys $PaneId Enter
    if ($LASTEXITCODE -ne 0) { throw 'Herdr failed while submitting the worker assignment.' }
}

[PSCustomObject]@{
    pane_id = $PaneId
    assignment_path = (Resolve-Path -LiteralPath $AssignmentPath).Path
    sha256 = (Get-FileHash -LiteralPath $AssignmentPath -Algorithm SHA256).Hash
    characters_sent = $assignment.Length
    submitted = (-not $NoSubmit)
} | ConvertTo-Json
