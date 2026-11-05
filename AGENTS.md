# AutoHotkey (AHK) 150% Expert Workspace Rules

В этом рабочем пространстве (`c:\Users\Arch\Desktop\AHK`) агент работает в режиме **AHK-эксперта (AutoHotkey v1.1 и v2, WinAPI, UIA, игровые и системные биндеры)**.

## 1. Локальное окружение AutoHotkey
- **Установленная версия**: AutoHotkey `v1.1.37.02` в `C:\Program Files\AutoHotkey\`
- **Исполняемые файлы**:
  - `C:\Program Files\AutoHotkey\AutoHotkeyU64.exe` — основной 64-битный Unicode интерпретатор.
  - `C:\Program Files\AutoHotkey\AutoHotkeyU64_UIA.exe` — интерпретатор с UIAccess (обход ограничений окон с повышенными правами без полного UAC-промпта).
  - `C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe` — компилятор в `.exe` (базовый бинарник: `C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin`).
  - `C:\Program Files\AutoHotkey\WindowSpy.ahk` — утилита для определения `ahk_class`, `ahk_exe`, контролов и координат.
- **Файлы проекта**:
  - `АХК УГИБДД.ahk` — крупный RP-биндер (AHK v1.1) для MTA Province (УГИБДД) с GUI, звуковыми оповещениями (`1.mp3`), иконкой (`ahkgibdd.ico`), чтением `console.log`, авто-окончаниями по полу (`Ok1`–`Ok11`) и хранением настроек в `%A_Temp%\gibdd.egl`.

## 2. Критические требования к коду AHK v1.1
1. **Кодировка UTF-8 with BOM (`0xEF 0xBB 0xBF`)**:
   - Любой `.ahk` файл с кириллицей **обязан** сохраняться в кодировке **UTF-8 со спецификацией (with BOM)**.
   - Инструменты редактирования текста могут сбрасывать BOM. После **каждого** изменения `.ahk` файла запускай:
     `powershell -ExecutionPolicy Bypass -File "c:\Users\Arch\Desktop\AHK\.agents\skills\ahk-expert\scripts\ahk-tools.ps1" -Action fix-bom -File "c:\Users\Arch\Desktop\AHK\АХК УГИБДД.ahk"`
   - Внимание: в функции `GetTryRes()` внутри `АХК УГИБДД.ahk` строки `РќРµСѓРґР°С‡РЅРѕ` и `РЈРґР°С‡РЅРѕ` намеренно записаны в таком виде для сопоставления чтения `console.log` — не меняй их без явной просьбы пользователя и проверки кодировки чтения лога (`FileEncoding`).
2. **Ввод текста, раскладка и спецсимволы**:
   - В MTA Province ввод команд и отыгровок осуществляется через консоль `F8` (`SendPlay {F8}^A{Delete}%TextBind%{Enter}{F8}`).
   - Перед отправкой текста обязательно выставляй русскую раскладку (`SetLocaleRu()` -> `SendMessage, 0x50,, 0x4190419,, A`) и выключай CapsLock (`SetCapsOff()`).
   - Экранируй спецсимволы AHK (`#`, `!`, `^`, `+`, `&`) через функцию `Encoded(Target)`.
3. **Проверка синтаксиса и компиляция**:
   - После внесения правок проверяй скрипт через `ahk-tools.ps1 -Action check`.
   - При компиляции в `.exe` используй `ahk-tools.ps1 -Action compile`, который автоматически подставляет `ahkgibdd.ico` и `Unicode 64-bit.bin`.
