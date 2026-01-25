# Set UTF-8 output encoding
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Fetch all gopass entries
$entries = gopass list --flat
if (-not $entries) {
    Write-Host "⚠️ No gopass entries found." -ForegroundColor Yellow
    exit 1
}

# Split entries into array
$entriesArray = $entries -split "`n"

# Display entries with index numbers
Write-Host "`n🔐 Available entries:" -ForegroundColor Cyan
for ($i = 0; $i -lt $entriesArray.Count; $i++) {
    Write-Host "$($i+1). $($entriesArray[$i])"
}

# Prompt user to select an entry
$index = Read-Host "`nEnter the number of the entry to delete"
if (-not ($index -match '^\d+$') -or $index -lt 1 -or $index -gt $entriesArray.Count) {
    Write-Host "❌ Invalid selection." -ForegroundColor Red
    exit 1
}

# Get the selected entry
$selectedEntry = $entriesArray[$index - 1]

# Confirm deletion
Write-Host "`n⚠️ You selected: $selectedEntry"
$confirm = Read-Host "Are you sure you want to delete this entry? (y/n)"

if ($confirm -ieq 'y') {
    try {
        gopass rm -f $selectedEntry
        Write-Host "✅ Entry '$selectedEntry' has been deleted." -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to delete: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "❎ Deletion cancelled." -ForegroundColor Yellow
}
