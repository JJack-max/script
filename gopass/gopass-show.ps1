# Force PowerShell output encoding to UTF-8 to avoid character issues
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# # Set unlock password (for production, consider reading from env or vault)
# $correctPassword = "MySecurePassword123"

# # Prompt for unlock password
# $password = Read-Host "Enter password to continue" -AsSecureString
# $passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
#     [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
# )

# if ($passwordPlain -ne $correctPassword) {
#     Write-Host "❌ Incorrect password. Exiting." -ForegroundColor Red
#     exit 1
# }

# Fetch all gopass entries
$entries = gopass list --flat
if (-not $entries) {
    Write-Host "⚠️ No gopass entries found." -ForegroundColor Yellow
    exit 1
}

# Display numbered entry list
Write-Host "`n🗂 Available entries:" -ForegroundColor Cyan
$entriesArray = $entries -split "`n"
for ($i = 0; $i -lt $entriesArray.Count; $i++) {
    Write-Host "$($i+1). $($entriesArray[$i])"
}

# Prompt user to select an entry
$index = Read-Host "`nEnter the number of the entry to select"
if (-not ($index -match '^\d+$')) {
   Write-Host "❌ Invalid selection." -ForegroundColor Red
   exit 1
}

$selectedEntry = $entriesArray[$index - 1]
Write-Host "`n🔎 Selected: $selectedEntry"

# Prompt for action
Write-Host "`nChoose an action:"
Write-Host "1. 📋 Copy password to clipboard (clears in 10 seconds)"
Write-Host "2. 📄 Show full entry content"
$action = Read-Host "Enter action number"

switch ($action) {
    '1' {
        try {
            $secret = gopass show -o $selectedEntry
            if ([string]::IsNullOrWhiteSpace($secret)) {
                throw "Password is empty or could not be retrieved."
            }

            Set-Clipboard -Value $secret
            Write-Host "`n✅ Password copied to clipboard." -ForegroundColor Green
            # Countdown timer
            for ($countdown = 10; $countdown -gt 0; $countdown--) {
                Write-Host "⏳ Clipboard will be cleared in $countdown seconds..." -ForegroundColor DarkCyan -NoNewline
                Start-Sleep -Seconds 1
                Write-Host "`r" -NoNewline  # Carriage return to overwrite the line
            }
            Write-Host "" # New line after countdown

            # Confirm clipboard still holds the same password before clearing
            if ((Get-Clipboard) -eq $secret) {
                Set-Clipboard -Value " "  # Replace with whitespace to avoid null
                Write-Host "🧹 Time expired — clipboard cleared." -ForegroundColor Yellow
            } else {
                Write-Host "⚠️ Clipboard was modified before timeout — not cleared." -ForegroundColor DarkYellow
            }
        } catch {
            Write-Host "`n❌ Failed to copy password: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    '2' {
        Write-Host "`n🔐 Full entry content:" -ForegroundColor Cyan
        gopass show $selectedEntry
    }
    default {
        Write-Host "❌ Invalid action selected." -ForegroundColor Red
    }
}
