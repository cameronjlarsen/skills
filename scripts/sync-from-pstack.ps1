# Phase A: assert poteto-routed playbooks are not forked locally,
# and cameron-owned shipping playbooks do not regress to GitHub/poteto ship paths.
#
# Usage (from repo root):
#   pwsh ./scripts/sync-from-pstack.ps1
#   pwsh ./scripts/sync-from-pstack.ps1 -PotetoPlaybooksDir <path-to-poteto-mode/playbooks>

param(
	[string]$PotetoPlaybooksDir = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$cameronPlaybooks = Join-Path $repoRoot "skills\cameron-mode\playbooks"
$routedList = Join-Path $PSScriptRoot "phase-a-poteto-routed.txt"
$ownedList = Join-Path $PSScriptRoot "cameron-owned-playbooks.txt"
$failures = New-Object System.Collections.Generic.List[string]

function Resolve-PotetoPlaybooksDir {
	param([string]$Explicit)
	if ($Explicit -and (Test-Path $Explicit)) { return (Resolve-Path $Explicit).Path }

	$cacheRoot = Join-Path $env:USERPROFILE ".cursor\plugins\cache\cursor-public\pstack"
	if (-not (Test-Path $cacheRoot)) { return $null }

	$hit = Get-ChildItem $cacheRoot -Directory |
		ForEach-Object {
			$p = Join-Path $_.FullName "skills\poteto-mode\playbooks"
			if (Test-Path $p) { [pscustomobject]@{ Path = $p; Time = $_.LastWriteTimeUtc } }
		} |
		Sort-Object Time -Descending |
		Select-Object -First 1

	if ($hit) { return $hit.Path }
	return $null
}

$potetoDir = Resolve-PotetoPlaybooksDir -Explicit $PotetoPlaybooksDir
if (-not $potetoDir) {
	$failures.Add("Could not find poteto-mode playbooks. Install pstack or pass -PotetoPlaybooksDir.")
} else {
	Write-Host "Using poteto playbooks: $potetoDir"
}

$routed = Get-Content $routedList | Where-Object { $_.Trim() -ne "" }
foreach ($name in $routed) {
	$local = Join-Path $cameronPlaybooks $name
	if (Test-Path $local) {
		$failures.Add("Phase A routed playbook still forked locally: $name")
	}
	if ($potetoDir) {
		$upstream = Join-Path $potetoDir $name
		if (-not (Test-Path $upstream)) {
			$failures.Add("Upstream poteto playbook missing: $name")
		}
	}
}

$owned = Get-Content $ownedList | Where-Object { $_.Trim() -ne "" }
foreach ($name in $owned) {
	$local = Join-Path $cameronPlaybooks $name
	if (-not (Test-Path $local)) {
		$failures.Add("Cameron-owned playbook missing: $name")
		continue
	}
	$text = Get-Content $local -Raw
	foreach ($bad in @("Opening a PR", "gh pr ", "poteto-agent", "watch-pr")) {
		# opening-ado-pr may mention poteto only in comments; forbid ship tooling strings
		if ($text -match [regex]::Escape($bad)) {
			$failures.Add("${name}: forbidden pattern '$bad'")
		}
	}
}

if ($failures.Count -gt 0) {
	Write-Host "FAIL:" -ForegroundColor Red
	$failures | ForEach-Object { Write-Host " - $_" }
	exit 1
}

Write-Host "OK: Phase A routing manifests hold; cameron-owned playbooks pass forbidden-pattern check."
exit 0
