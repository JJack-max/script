# Use the script's own directory to find alias file
$aliasFile = Join-Path -Path $PSScriptRoot -ChildPath "alias"

if (-not (Test-Path $aliasFile)) {
    Write-Error "Alias file not found: $aliasFile"
    exit 1
}

$aliasContent = Get-Content -Path $aliasFile -Raw

$profileDir = Split-Path -Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

Set-Content -Path $PROFILE -Value $aliasContent -Encoding UTF8

Write-Host "Alias content successfully written to $PROFILE"
