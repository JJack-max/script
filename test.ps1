function Compress-String {
    param([string]$Text)

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $ms = New-Object System.IO.MemoryStream
    $gzip = New-Object System.IO.Compression.DeflateStream(
        $ms, 
        [System.IO.Compression.CompressionMode]::Compress,
        $true
    )
    $gzip.Write($bytes, 0, $bytes.Length)
    $gzip.Close()
    return $ms.ToArray()
}

function Decompress-Bytes {
    param([byte[]]$Bytes)

    $input = New-Object System.IO.MemoryStream
    $input.Write($Bytes, 0, $Bytes.Length)
    $input.Position = 0

    $decompress = New-Object System.IO.Compression.DeflateStream(
        $input,
        [System.IO.Compression.CompressionMode]::Decompress
    )

    $output = New-Object System.IO.MemoryStream
    $buffer = New-Object byte[] 1024
    while (($read = $decompress.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $output.Write($buffer, 0, $read)
    }
    $decompress.Close()
    return [System.Text.Encoding]::UTF8.GetString($output.ToArray())
}

function Encrypt-Text {
    param([string]$Text)

    $key = [Text.Encoding]::UTF8.GetBytes("mysecretkey12345") # 16字节密钥
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Mode = 'ECB'
    $aes.Padding = 'PKCS7'
    $aes.Key = $key

    $compressed = Compress-String -Text $Text

    $encryptor = $aes.CreateEncryptor()
    $encrypted = $encryptor.TransformFinalBlock($compressed, 0, $compressed.Length)

    [Convert]::ToBase64String($encrypted).Replace('+','-').Replace('/','_').TrimEnd('=')
}

function Decrypt-Text {
    param([string]$Encoded)

    $key = [Text.Encoding]::UTF8.GetBytes("mysecretkey12345") # 同样密钥
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Mode = 'ECB'
    $aes.Padding = 'PKCS7'
    $aes.Key = $key

    # URL-safe base64 还原
    $padded = $Encoded.Replace('-','+').Replace('_','/')
    switch ($padded.Length % 4) {
        2 {$padded += '=='}
        3 {$padded += '='}
    }

    $data = [Convert]::FromBase64String($padded)
    $decryptor = $aes.CreateDecryptor()
    $decrypted = $decryptor.TransformFinalBlock($data, 0, $data.Length)

    Decompress-Bytes -Bytes $decrypted
}

# 示例测试
$original = "但愿人长久，千里共婵娟"
$encrypted = Encrypt-Text -Text $original
$decrypted = Decrypt-Text -Encoded $encrypted

Write-Host "原文: $original"
Write-Host "密文（短）: $encrypted"
Write-Host "解密结果: $decrypted"
