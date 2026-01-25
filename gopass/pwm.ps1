# pwm.ps1
Write-Host "Select an action:"
Write-Host "1. Create password"
Write-Host "2. Show password"
Write-Host "3. Delete password"
$choice = Read-Host "Enter choice (1/2/3)"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

switch ($choice) {
    "1" {
        & "$scriptDir\gopass-create.ps1"
    }
    "2" {
        & "$scriptDir\gopass-show.ps1"
    }
    "3" {
        & "$scriptDir\gopass-delete.ps1"
    }
    default {
        Write-Host "Invalid selection. Exiting." -ForegroundColor Red
    }
}
