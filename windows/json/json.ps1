# JSON 工具: 格式化和压缩
# 用法示例:
#   .\json.ps1 format <file>   - 格式化 JSON 文件
#   .\json.ps1 minify <file>   - 压缩 JSON 文件
#   .\json.ps1 help            - 显示帮助信息

param(
    [Parameter(Position=0)]
    [string]$Command,
    
    [Parameter(Position=1)]
    [string]$File
)

function Show-Help {
    Write-Host "Usage: json <command> [file]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  format <file>   Format the JSON file."
    Write-Host "  minify <file>   Minify the JSON file."
    Write-Host "  help            Show this help message."
}

# 检查文件是否存在
function Test-JsonFile {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        Write-Error "Error: File '$FilePath' not found."
        exit 1
    }
}

# JSON 格式化函数
function Format-JsonFile {
    param([string]$FilePath)
    
    Test-JsonFile $FilePath
    
    try {
        $jsonContent = Get-Content $FilePath -Raw -Encoding UTF8
        $jsonObject = $jsonContent | ConvertFrom-Json
        $formattedJson = $jsonObject | ConvertTo-Json -Depth 100
        
        # 写入文件，使用 UTF8 编码
        $formattedJson | Out-File $FilePath -Encoding UTF8
        Write-Host "Formatted $FilePath successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Error: Failed to format $FilePath - $($_.Exception.Message)"
        exit 1
    }
}

# JSON 压缩函数
function Compress-JsonFile {
    param([string]$FilePath)
    
    Test-JsonFile $FilePath
    
    try {
        $jsonContent = Get-Content $FilePath -Raw -Encoding UTF8
        $jsonObject = $jsonContent | ConvertFrom-Json
        $compressedJson = $jsonObject | ConvertTo-Json -Depth 100 -Compress
        
        # 写入文件，使用 UTF8 编码
        $compressedJson | Out-File $FilePath -Encoding UTF8
        Write-Host "Minified $FilePath successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Error: Failed to minify $FilePath - $($_.Exception.Message)"
        exit 1
    }
}

# 检查是否至少有一个参数
if (-not $Command) {
    Show-Help
    exit 1
}

# 解析命令
switch ($Command.ToLower()) {
    "format" {
        if (-not $File) {
            Write-Error "Error: No file specified."
            exit 1
        }
        Format-JsonFile $File
    }
    "minify" {
        if (-not $File) {
            Write-Error "Error: No file specified."
            exit 1
        }
        Compress-JsonFile $File
    }
    { $_ -in @("help", "--help", "-h") } {
        Show-Help
    }
    default {
        Write-Error "Error: Unknown command '$Command'"
        Show-Help
        exit 1
    }
}