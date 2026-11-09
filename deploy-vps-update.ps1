param(
    [Parameter(Mandatory = $false)]
    [string]$Version,

    [Parameter(Mandatory = $false)]
    [int]$VersionCode,

    [Parameter(Mandatory = $false)]
    [string]$Title,

    [Parameter(Mandatory = $false)]
    [string]$Changelog,

    [Parameter(Mandatory = $false)]
    [string]$VpsHost = '152.234.229.245',

    [Parameter(Mandatory = $false)]
    [string]$RemoteDir = '/opt/ahk-tablet-relay/public'
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

$workspace = 'c:\Users\Arch\Desktop\AHK'
$ahkFile   = Join-Path $workspace 'АХК УГИБДД.ahk'
$exeFile   = Join-Path $workspace 'АХК УГИБДД.exe'
$icoFile   = Join-Path $workspace 'ahkgibdd.ico'
$verFile   = Join-Path $workspace 'version.json'
$toolsPs1  = Join-Path $workspace '.agents\skills\ahk-expert\scripts\ahk-tools.ps1'

Write-Host '==========================================================' -ForegroundColor Cyan
Write-Host ' [VPS DEPLOY] PUBLISHING AHK UPDATE TO VPS' -ForegroundColor Cyan
Write-Host (' Target Host: ' + $VpsHost) -ForegroundColor Cyan
Write-Host '==========================================================' -ForegroundColor Cyan

# 1. UTF-8 with BOM
Write-Host '1. Checking UTF-8 with BOM...' -ForegroundColor Yellow
& powershell -ExecutionPolicy Bypass -File $toolsPs1 -Action fix-bom -File $ahkFile

# 2. Syntax Check
Write-Host '2. Checking AHK syntax...' -ForegroundColor Yellow
& powershell -ExecutionPolicy Bypass -File $toolsPs1 -Action check -File $ahkFile

# 3. Compile
Write-Host '3. Compiling AHK...' -ForegroundColor Yellow
$deployExe = Join-Path $workspace 'deploy_build.exe'
if (Test-Path $deployExe) { Remove-Item $deployExe -Force -ErrorAction SilentlyContinue }
& powershell -ExecutionPolicy Bypass -File $toolsPs1 -Action compile -File $ahkFile -Icon $icoFile -OutExe $deployExe
if (-not (Test-Path $deployExe)) {
    Write-Error 'Compilation failed: deploy_build.exe not produced'
}
try {
    Copy-Item -Path $deployExe -Destination $exeFile -Force -ErrorAction Stop
    Write-Host 'Local АХК УГИБДД.exe updated.' -ForegroundColor Green
} catch {
    Write-Host 'Local АХК УГИБДД.exe is currently locked by active process; deploying fresh binary directly to VPS.' -ForegroundColor Yellow
}

# 4. Update version.json if params given
if ($Version -or $VersionCode -or $Title -or $Changelog) {
    Write-Host '4. Updating version.json...' -ForegroundColor Yellow
    $curVerObj = Get-Content $verFile -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($Version)     { $curVerObj.version = $Version }
    if ($VersionCode) { $curVerObj.version_code = $VersionCode }
    if ($Title)       { $curVerObj.title = $Title }
    if ($Changelog)   { $curVerObj.changelog = $Changelog }
    $curVerObj.release_date = (Get-Date).ToString('yyyy-MM-dd')
    $curVerObj.download_url = 'http://' + $VpsHost + ':3000/download/exe'
    $curVerObj.download_mirror = 'http://' + $VpsHost + ':3000/download/exe'
    $curVerObj.ahk_url = 'http://' + $VpsHost + ':3000/download/ahk'
    $curVerObj.ahk_mirror = 'http://' + $VpsHost + ':3000/download/ahk'

    $jsonOut = $curVerObj | ConvertTo-Json -Depth 5
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($verFile, $jsonOut, $utf8NoBom)
    Write-Host ('Version updated: ' + $curVerObj.version) -ForegroundColor Green
}

# 5. Upload files to VPS
Write-Host '5. Uploading files to VPS...' -ForegroundColor Yellow
$itemsToUpload = @(
    @{ Local = $verFile; Remote = 'version.json' },
    @{ Local = $ahkFile; Remote = 'АХК УГИБДД.ahk' },
    @{ Local = $deployExe; Remote = 'АХК УГИБДД.exe' }
)

foreach ($item in $itemsToUpload) {
    $localPath = $item.Local
    $remoteName = $item.Remote
    $size = (Get-Item $localPath).Length
    Write-Host ('Uploading ' + $remoteName + ' (' + $size + ' bytes)...')
    $targetRemote = 'root@' + $VpsHost + ':' + $RemoteDir + '/' + $remoteName
    & scp.exe -o BatchMode=yes -o StrictHostKeyChecking=no $localPath $targetRemote
    if ($LASTEXITCODE -eq 0) {
        Write-Host ('OK: ' + $remoteName) -ForegroundColor Green
    } else {
        Write-Host ('FAILED: ' + $remoteName) -ForegroundColor Red
        exit 1
    }
}
if (Test-Path $deployExe) { Remove-Item $deployExe -Force -ErrorAction SilentlyContinue }

Write-Host '==========================================================' -ForegroundColor Green
Write-Host ' [SUCCESS] UPDATE DEPLOYED TO VPS!' -ForegroundColor Green
Write-Host (' Version API : http://' + $VpsHost + ':3000/api/version') -ForegroundColor Green
Write-Host (' Download EXE: http://' + $VpsHost + ':3000/download/exe') -ForegroundColor Green
Write-Host (' Download AHK: http://' + $VpsHost + ':3000/download/ahk') -ForegroundColor Green
Write-Host ' All clients will now download updates directly from your VPS!' -ForegroundColor Green
Write-Host '==========================================================' -ForegroundColor Green
