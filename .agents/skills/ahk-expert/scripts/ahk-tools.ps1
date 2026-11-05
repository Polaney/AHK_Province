param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("check", "fix-bom", "compile", "run", "stop", "spy", "info")]
    [string]$Action,

    [Parameter(Mandatory = $false)]
    [string]$File = "c:\Users\Arch\Desktop\AHK\АХК УГИБДД.ahk",

    [Parameter(Mandatory = $false)]
    [string]$Icon = "c:\Users\Arch\Desktop\AHK\ahkgibdd.ico",

    [Parameter(Mandatory = $false)]
    [switch]$UIA
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

$AhkDir      = "C:\Program Files\AutoHotkey"
$AhkU64      = Join-Path $AhkDir "AutoHotkeyU64.exe"
$AhkU64UIA   = Join-Path $AhkDir "AutoHotkeyU64_UIA.exe"
$Ahk2Exe     = Join-Path $AhkDir "Compiler\Ahk2Exe.exe"
$AhkBin64    = Join-Path $AhkDir "Compiler\Unicode 64-bit.bin"
$WindowSpy   = Join-Path $AhkDir "WindowSpy.ahk"

function Test-Utf8Bom {
    param([string]$FilePath)
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return $true
    }
    return $false
}

function Repair-Utf8Bom {
    param([string]$FilePath)
    if (-not (Test-Path -LiteralPath $FilePath)) {
        Write-Error "Файл не найден: $FilePath"
    }
    if (Test-Utf8Bom -FilePath $FilePath) {
        Write-Host "[OK] UTF-8 with BOM уже присутствует: $FilePath" -ForegroundColor Green
        return
    }
    $content = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($FilePath, $content, $utf8Bom)
    Write-Host "[FIXED] Добавлен заголовок UTF-8 with BOM (EF BB BF): $FilePath" -ForegroundColor Cyan
}

switch ($Action) {
    "fix-bom" {
        Repair-Utf8Bom -FilePath $File
    }

    "check" {
        if (-not (Test-Path -LiteralPath $File)) {
            Write-Error "Файл не найден: $File"
        }
        $hasBom = Test-Utf8Bom -FilePath $File
        if (-not $hasBom) {
            Write-Host "[WARN] Отсутствует UTF-8 BOM! Исправляю автоматически..." -ForegroundColor Yellow
            Repair-Utf8Bom -FilePath $File
        } else {
            Write-Host "[OK] Кодировка: UTF-8 with BOM (EF BB BF)" -ForegroundColor Green
        }

        # Создаём временную копию с ExitApp в начале автовыполнения для быстрой проверки компилятором/парсером AHK
        $tempCheck = Join-Path $env:TEMP ("ahk_syntax_check_" + [Guid]::NewGuid().ToString("N") + ".ahk")
        try {
            $rawText = [System.IO.File]::ReadAllText($File, [System.Text.Encoding]::UTF8)
            $checkContent = "#ErrorStdOut UTF-8`r`nExitApp`r`n" + $rawText
            $utf8Bom = New-Object System.Text.UTF8Encoding($true)
            [System.IO.File]::WriteAllText($tempCheck, $checkContent, $utf8Bom)

            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = $AhkU64
            $pinfo.Arguments = "/ErrorStdOut=UTF-8 `"$tempCheck`""
            $pinfo.RedirectStandardError = $true
            $pinfo.RedirectStandardOutput = $true
            $pinfo.UseShellExecute = $false
            $pinfo.StandardErrorEncoding = [System.Text.Encoding]::UTF8
            $pinfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8

            $proc = [System.Diagnostics.Process]::Start($pinfo)
            $finished = $proc.WaitForExit(5000)
            if (-not $finished) {
                $proc.Kill()
                Write-Host "[WARN] Проверка превысила тайм-аут 5с (возможно, директивы до автовыполнения запустили ожидание)." -ForegroundColor Yellow
            } else {
                $stderr = $proc.StandardError.ReadToEnd()
                $stdout = $proc.StandardOutput.ReadToEnd()
                if ($proc.ExitCode -ne 0 -or $stderr.Trim().Length -gt 0) {
                    Write-Host "[ERROR] Найдена синтаксическая ошибка в скрипте:" -ForegroundColor Red
                    Write-Host ($stderr.Replace($tempCheck, $File)) -ForegroundColor Red
                    exit 1
                } else {
                    $lines = ($rawText -split "`n").Count
                    Write-Host "[OK] Синтаксис AHK проверен успешно! Строк: $lines, код выхода: 0." -ForegroundColor Green
                }
            }
        } finally {
            if (Test-Path -LiteralPath $tempCheck) {
                Remove-Item -LiteralPath $tempCheck -Force -ErrorAction SilentlyContinue
            }
        }
    }

    "compile" {
        Repair-Utf8Bom -FilePath $File
        $outExe = [System.IO.Path]::ChangeExtension($File, ".exe")
        $argsList = @("/in", "`"$File`"", "/out", "`"$outExe`"", "/bin", "`"$AhkBin64`"")
        if (Test-Path -LiteralPath $Icon) {
            $argsList += @("/icon", "`"$Icon`"")
        }
        Write-Host "Компиляция: $File -> $outExe ..." -ForegroundColor Cyan
        $proc = Start-Process -FilePath $Ahk2Exe -ArgumentList ($argsList -join " ") -Wait -PassThru -NoNewWindow
        if ($proc.ExitCode -eq 0 -and (Test-Path -LiteralPath $outExe)) {
            $sizeKb = [Math]::Round((Get-Item -LiteralPath $outExe).Length / 1KB, 1)
            Write-Host "[OK] Успешно скомпилировано: $outExe ($sizeKb KB)" -ForegroundColor Green
        } else {
            Write-Error "Ошибка компиляции Ahk2Exe (ExitCode: $($proc.ExitCode))"
        }
    }

    "run" {
        Repair-Utf8Bom -FilePath $File
        $exeToUse = if ($UIA -and (Test-Path -LiteralPath $AhkU64UIA)) { $AhkU64UIA } else { $AhkU64 }
        Start-Process -FilePath $exeToUse -ArgumentList "`"$File`""
        Write-Host "[OK] Скрипт запущен через $(Split-Path $exeToUse -Leaf): $File" -ForegroundColor Green
    }

    "stop" {
        $procs = Get-Process -Name "AutoHotkey*" -ErrorAction SilentlyContinue
        if ($procs) {
            $procs | Stop-Process -Force
            Write-Host "[OK] Остановлено процессов AutoHotkey: $($procs.Count)" -ForegroundColor Yellow
        } else {
            Write-Host "[INFO] Активных процессов AutoHotkey не найдено." -ForegroundColor Gray
        }
    }

    "spy" {
        Start-Process -FilePath $AhkU64 -ArgumentList "`"$WindowSpy`""
        Write-Host "[OK] Запущен Window Spy." -ForegroundColor Green
    }

    "info" {
        $ver = (Get-Item $AhkU64).VersionInfo.FileVersion
        Write-Host "AutoHotkey Version : $ver"
        Write-Host "AutoHotkey Path    : $AhkDir"
        Write-Host "Target Script      : $File"
        Write-Host "UTF-8 with BOM     : $(Test-Utf8Bom -FilePath $File)"
    }
}
