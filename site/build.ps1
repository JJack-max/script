# .NET 8 Web API Linux Deployment Build Script (Minimal)
# This script creates a self-contained, trimmed deployment for Linux

param(
    [string]$OutputDir = "dist",
    [string]$ProjectName = "site"
)

# Ensure we're in the project directory
Set-Location -Path $PSScriptRoot

Write-Host "Starting minimal build process for $ProjectName..." -ForegroundColor Green

# Clean previous builds
if (Test-Path $OutputDir) {
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $OutputDir
}

# Create output directory
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

# Publish the application for Linux with maximum optimizations
Write-Host "Publishing application for Linux (x64)..." -ForegroundColor Yellow
dotnet publish -c Release -r linux-x64 --self-contained true `
  -p:PublishTrimmed=false `
  -p:PublishSingleFile=true `
  -p:IncludeNativeLibrariesForSelfExtract=true `
  -p:EnableCompressionInSingleFile=true `
  -p:DebuggerSupport=false `
  -p:EnableUnsafeBinaryFormatterSerialization=false `
  -p:EnableUnsafeUTF7Encoding=false `
  -p:HttpActivityPropagationSupport=false `
  -p:InvariantGlobalization=true `
  -o $OutputDir

# Display final package information
Write-Host "Build completed successfully!" -ForegroundColor Green
$size = (Get-ChildItem -Path $OutputDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "Total package size: $($size.ToString("F2")) MB" -ForegroundColor Cyan

Write-Host "Contents of deployment package:" -ForegroundColor Yellow
Get-ChildItem -Path $OutputDir | Format-Table Name, Length -AutoSize

Write-Host "Deployment package is ready at: $OutputDir" -ForegroundColor Green
Write-Host "To run on Linux:" -ForegroundColor Yellow
Write-Host "  1. Copy the 'site' executable to your Linux server" -ForegroundColor White
Write-Host "  2. Set execute permissions: chmod +x site" -ForegroundColor White
Write-Host "  3. Run directly: ./site" -ForegroundColor White
Write-Host "  4. The application will listen on port 8080 by default" -ForegroundColor White