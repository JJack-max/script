# WSL VHDX Compression Script
# This script automatically shuts down WSL and compresses ext4.vhdx files to reclaim disk space
# Usage: .\compress-wsl.ps1 [-DryRun]

param (
    [switch]$DryRun  # If -DryRun is specified, only print paths, do not compress
)

function Stop-WSL {
    Write-Host "Checking WSL status..." -ForegroundColor Yellow
    
    # Check if any WSL distributions are running
    $wslStatus = wsl --list --running 2>$null
    if ($LASTEXITCODE -eq 0 -and $wslStatus -match "\S") {
        Write-Host "WSL distributions are running. Shutting down WSL..." -ForegroundColor Yellow
        
        # Shutdown WSL
        wsl --shutdown
        
        # Wait a moment for shutdown to complete
        Start-Sleep -Seconds 3
        
        # Verify shutdown
        $wslStatus = wsl --list --running 2>$null
        if ($LASTEXITCODE -eq 0 -and $wslStatus -match "\S") {
            Write-Error "Failed to shutdown WSL. Please manually stop all WSL distributions before running this script."
            return $false
        }
        
        Write-Host "✅ WSL has been shut down successfully." -ForegroundColor Green
    } else {
        Write-Host "✅ WSL is not running." -ForegroundColor Green
    }
    
    return $true
}

function Optimize-WSLVHDX {
    # Ensure WSL is shut down before proceeding
    if (-not (Stop-WSL)) {
        return
    }
    
    $user = $env:USERNAME
    $basePath = "C:\Users\$user\AppData\Local\wsl"

    if (-not (Test-Path $basePath)) {
        Write-Error "WSL base directory not found: $basePath"
        return
    }

    $vhdxFiles = Get-ChildItem -Path $basePath -Recurse -Filter "ext4.vhdx" -ErrorAction SilentlyContinue

    if ($vhdxFiles.Count -eq 0) {
        Write-Warning "No ext4.vhdx files found."
        return
    }

    foreach ($file in $vhdxFiles) {
        Write-Host "Found VHDX file: " -NoNewline
        Write-Host $file.FullName -ForegroundColor Cyan

        if ($DryRun) {
            continue
        }

        try {
            Optimize-VHD -Path $file.FullName -Mode Full -ErrorAction Stop
            Write-Host "✅ Compression completed: $($file.FullName)" -ForegroundColor Green
        }
        catch {
            Write-Warning "⚠️ Compression failed: $($file.FullName)`nReason: $($_.Exception.Message)"
        }
    }
}

# Run the function
Optimize-WSLVHDX
