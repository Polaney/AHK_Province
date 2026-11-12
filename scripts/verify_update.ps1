param(
    [Parameter(Mandatory=$true)][string]$TargetFile,
    [Parameter(Mandatory=$true)][string]$PubXml,
    [Parameter(Mandatory=$true)][string]$ExpHash,
    [Parameter(Mandatory=$true)][string]$ExpSig
)

try {
    if (-not (Test-Path $TargetFile)) {
        Write-Output "FILE_NOT_FOUND"
        exit 1
    }

    $bytes = [System.IO.File]::ReadAllBytes($TargetFile)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $calcHash = [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace("-","").ToLower()

    if ($calcHash -ne $ExpHash.ToLower().Trim()) {
        Write-Output "HASH_MISMATCH"
        exit 2
    }

    $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
    $rsa.FromXmlString($PubXml)
    $sigBytes = [Convert]::FromBase64String($ExpSig.Trim())
    $isValid = $rsa.VerifyData($bytes, "SHA256", $sigBytes)

    if ($isValid) {
        Write-Output "VALID"
        exit 0
    } else {
        Write-Output "INVALID_SIGNATURE"
        exit 3
    }
} catch {
    Write-Output "ERROR: $_"
    exit 4
}
